//
//  Cached Image.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Dependencies
import Foundation
import MarkdownUI
import Nuke
import NukeUI
import QuickLook
import SwiftUI

struct CachedImage: View {
    @Dependency(\.notifier) var notifier
    let url: URL?
    let shouldExpand: Bool
    let hasContextMenu: Bool
    
    // state vars to track the current image size and whether that size needs to be recomputed when the image actually loads. Combined with the image size cache, this produces good scrolling behavior except in the case where we scroll past an image and it derenders before it ever gets a chance to load, in which case that image will cause a slight hiccup on the way back up. That's kind of an unsolvable problem, since we can't know the size before we load the image at all, but that's fine because it shouldn't really happen during normal use. If we really want to guarantee smooth feed scrolling we can squish any image with no cached size into a square, but that feels like squishing a lot of images for the sake of a fringe case.
    @State var size: CGSize
    let fixedSize: CGSize?
    @State var shouldRecomputeSize: Bool
    
    @EnvironmentObject private var imageDetailSheetState: ImageDetailSheetState
    
    var imageNotFound: () -> AnyView
    
    let maxHeight: CGFloat
    let screenWidth: CGFloat
    let contentMode: ContentMode
    let blurRadius: CGFloat
    let cornerRadius: CGFloat
    let errorBackgroundColor: Color
    
    // Optional callback triggered when the quicklook preview is presented on tap gesture.
    let onTapCallback: (() -> Void)?
    
    init(
        url: URL?,
        shouldExpand: Bool = true,
        hasContextMenu: Bool = false,
        maxHeight: CGFloat = .infinity,
        fixedSize: CGSize? = nil,
        imageNotFound: @escaping () -> AnyView = imageNotFoundDefault,
        errorBackgroundColor: Color = Color(uiColor: .systemGray4),
        blurRadius: CGFloat = 0,
        contentMode: ContentMode = .fit,
        onTapCallback: (() -> Void)? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.url = url
        self.shouldExpand = shouldExpand
        self.hasContextMenu = hasContextMenu
        self.maxHeight = maxHeight
        self.imageNotFound = imageNotFound
        self.errorBackgroundColor = errorBackgroundColor
        self.blurRadius = blurRadius
        self.contentMode = contentMode
        self.onTapCallback = onTapCallback
        self.cornerRadius = cornerRadius ?? 0
        
        self.screenWidth = UIScreen.main.bounds.width - (AppConstants.postAndCommentSpacing * 2)
        
        self.fixedSize = fixedSize
        // determine the size of the image
        if let fixedSize {
            // if we're given a size, just use it and to hell with the cache
            self._size = State(initialValue: fixedSize)
            self._shouldRecomputeSize = State(initialValue: false)
        } else if let url, let cachedSize = AppConstants.imageSizeCache.object(forKey: NSString(string: url.description)) {
            // if we find a size in the size cache, use it
            self._size = State(initialValue: cachedSize.size)
            self._shouldRecomputeSize = State(initialValue: false)
        } else if let url, let testImage = ImagePipeline.shared.cache[url] {
            // if we have nothing in the size cache but the image is ready, compute its size, use it, and cache it
            let ratio = screenWidth / testImage.image.size.width
            self._size = State(initialValue: CGSize(
                width: screenWidth,
                height: min(maxHeight, testImage.image.size.height * ratio)
            ))
            self._shouldRecomputeSize = State(initialValue: false)
            cacheImageSize()
        } else {
            // if there's nothing in the cache *and* no image, default to square :(
            self._size = State(initialValue: CGSize(width: screenWidth, height: screenWidth))
            self._shouldRecomputeSize = State(initialValue: true)
        }
    }
    
    var body: some View {
        LazyImage(url: url) { state in
            if let imageContainer = state.imageContainer {
                let image = Image(uiImage: imageContainer.image)
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .cornerRadius(cornerRadius)
                    .frame(idealWidth: size.width, maxHeight: size.height)
                    .if(fixedSize == nil) { content in
                        content.frame(idealWidth: size.width, maxHeight: size.height)
                    }
                    .ifLet(fixedSize) { fixedSize, content in
                        content.frame(width: fixedSize.width, height: fixedSize.height)
                    }
                    .blur(radius: blurRadius)
                    .clipped()
                    .allowsHitTesting(false)
                    .overlay(alignment: .top) {
                        // weeps in janky hack but this lets us tap the image only in the area we want
                        Rectangle()
                            .frame(maxHeight: size.height)
                            .opacity(0.00000000001)
                    }
                    .onAppear {
                        // if the image appears and its size isn't cached, compute its size and cache it
                        if shouldRecomputeSize {
                            let ratio = screenWidth / imageContainer.image.size.width
                            size = CGSize(
                                width: screenWidth,
                                height: min(maxHeight, imageContainer.image.size.height * ratio)
                            )
                            cacheImageSize()
                            shouldRecomputeSize = false
                        }
                    }
                    .if(shouldExpand) { content in
                        content
                            .onTapGesture {
                                imageDetailSheetState.url = url // show image detail
                                onTapCallback?()
                            }
                    }
                    .if(hasContextMenu) { content in
                        content
                            .contextMenu {
                                if hasContextMenu, let url {
                                    Button("Save", systemImage: Icons.import) {
                                        Task {
                                            do {
                                                let (data, _) = try await ImagePipeline.shared.data(for: url)
                                                let imageSaver = ImageSaver()
                                                imageSaver.writeToPhotoAlbum(imageData: data)
                                                await notifier.add(.success("Image saved"))
                                            } catch {
                                                print(String(describing: error))
                                            }
                                        }
                                    }
                                    
                                }
                                ShareLink(item: image, preview: .init("photo", image: image))
                            } preview: {
                                image
                                    .resizable()
                                    .onTapGesture {
                                        imageDetailSheetState.url = url
                                        onTapCallback?()
                                    }
                            }
                    }
            } else if state.error != nil {
                // Indicates an error
                imageNotFound()
                    .frame(idealWidth: size.width)
                    .frame(height: size.height)
                    .background(errorBackgroundColor)
            } else {
                ProgressView() // Acts as a placeholder
                    .frame(idealWidth: size.width)
                    .frame(height: size.height)
            }
        }
        .processors([
            .resize(
                size: size,
                contentMode: contentMode == .fill ? .aspectFill : .aspectFit
            )
        ])
        .frame(idealWidth: size.width)
        .frame(height: size.height)
        .onDisappear {
            // if the post disappears and the size still isn't computed, cache the fallback size. This ensures that the view doesn't resize while scrolling back up.
            if shouldRecomputeSize {
                cacheImageSize()
                shouldRecomputeSize = false
            }
        }
    }
    
    static func imageNotFoundDefault() -> AnyView {
        AnyView(Image(systemName: Icons.missing)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: AppConstants.thumbnailSize, maxHeight: AppConstants.thumbnailSize)
            .padding(AppConstants.postAndCommentSpacing)
            .background(Color(uiColor: .systemGray4))
            .foregroundColor(.secondary)
        )
    }
    
    /// Caches the current value of size
    private func cacheImageSize() {
        if let url {
            AppConstants.imageSizeCache.setObject(ImageSize(size: size), forKey: NSString(string: url.description))
        }
    }
}
