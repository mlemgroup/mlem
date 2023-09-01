//
//  Cached Image.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Foundation
import MarkdownUI
import Nuke
import SwiftUI

struct CachedImage: View, FullScreenActualContent {

    let url: URL?
    let shouldExpand: Bool

    // state vars to track the current image size and whether that size needs to be recomputed when the image actually loads. Combined with the image size cache, this produces good scrolling behavior except in the case where we scroll past an image and it derenders before it ever gets a chance to load, in which case that image will cause a slight hiccup on the way back up. That's kind of an unsolvable problem, since we can't know the size before we load the image at all, but that's fine because it shouldn't really happen during normal use. If we really want to guarantee smooth feed scrolling we can squish any image with no cached size into a square, but that feels like squishing a lot of images for the sake of a fringe case.
    @State var size: CGSize
    @State var shouldRecomputeSize: Bool
    @State private var quickLookUrl: URL?

    var imageNotFound: () -> AnyView

    let maxHeight: CGFloat
    let screenWidth: CGFloat
    let contentMode: ContentMode
    let cornerRadius: CGFloat

    // Optional callback triggered when the quicklook preview is dismissed
    let dismissCallback: (() -> Void)?

    init(
        url: URL?,
        shouldExpand: Bool = true,
        maxHeight: CGFloat = .infinity,
        fixedSize: CGSize? = nil,
        imageNotFound: @escaping (_: Error?) -> AnyView = imageNotFoundDefault,
        contentMode: ContentMode = .fit,
        dismissCallback: (() -> Void)? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.url = url
        self.shouldExpand = shouldExpand
        self.maxHeight = maxHeight
        self.imageNotFound = imageNotFound
        self.contentMode = contentMode
        self.dismissCallback = dismissCallback
        self.cornerRadius = cornerRadius ?? 0

        self.screenWidth = UIScreen.main.bounds.width - (AppConstants.postAndCommentSpacing * 2)

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

    var fullscreenContent: URL? { url }

    var body: some View {
        CoreMediaViewer(url: url) { error in
            // Indicates an error
            imageNotFound(error)
                .frame(width: size.width, height: size.height)
                .background(Color(uiColor: .systemGray4))
        } onImageLoad: { _, imageSize in
            // if the image appears and its size isn't cached, compute its size and cache it
            //            shareableImage = imageContainer.image
            if shouldRecomputeSize {
                let ratio = screenWidth / imageSize.width
                size = CGSize(width: screenWidth,
                              height: imageSize.height * ratio)
                shouldRecomputeSize = false
                cacheImageSize()
            }
        }
        .cornerRadius(cornerRadius)
        .frame(width: size.width, height: size.height)
        .fixedSize()
        .clipped()
        .allowsHitTesting(false)
        .overlay(alignment: .top) {
            // weeps in janky hack but this lets us tap the image only in the area we want
            Rectangle()
                .frame(maxHeight: size.height)
                .opacity(0.00000000001)
        }
    }
    static func imageNotFoundDefault(_ err: Error? = nil) -> AnyView {
     AnyView(
        VStack {
            Image(systemName: "questionmark.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: AppConstants.thumbnailSize, maxHeight: AppConstants.thumbnailSize)
            if let err = err {
                Text(err.localizedDescription)
            }
        }

         .padding(AppConstants.postAndCommentSpacing)
         .background(Color(uiColor: .systemGray4))
         .foregroundColor(.secondary)
     )
   }

   /**
    Caches the current value of size
    */
   private func cacheImageSize() {
     if let url {
       AppConstants.imageSizeCache.setObject(ImageSize(size: size), forKey: NSString(string: url.description))
     }
   }
}

#if DEBUG
struct CachedImagePreview: PreviewProvider {

    static var previews: some View {
        ForEach(testImageURLs) { testImageUrl in
            CachedImage(url: testImageUrl)
                .previewDisplayName(testImageUrl.pathExtension.capitalized)
        }
    }
}
#endif
