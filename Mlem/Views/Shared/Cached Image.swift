//
//  Cached Image.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import QuickLook
import NukeUI
import Nuke

struct CachedImage: View {
    
    let url: URL?
    let shouldExpand: Bool
    @State var bigPicMode: URL?
    let size: CGSize
    
    // TODO: Right now images that don't load in time get shoved into a square, which is good enough for now, but in the futured the image should be able to resize itself once the image loads and save that size for the future--perhaps look into a size cache that doesn't get as aggressively evicted
    
    init(url: URL?,
         shouldExpand: Bool = true,
         maxHeight: CGFloat = .infinity) {
        self.url = url
        self.shouldExpand = shouldExpand
        
        let screenWidth = UIScreen.main.bounds.width - (AppConstants.postAndCommentSpacing * 2)
        
        if let url, let testImage = ImagePipeline.shared.cache[url] {
            let ratio = screenWidth / testImage.image.size.width
            size = CGSize(width: screenWidth,
                          height: min(maxHeight, testImage.image.size.height * ratio))
        } else {
            size = CGSize(width: screenWidth, height: screenWidth)
        }
    }
    
    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.imageContainer {
                let imageView = Image(uiImage: image.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .allowsHitTesting(false)
                    .overlay(alignment: .top) {
                        // weeps in janky hack but this lets us tap the image only in the area we want
                        Rectangle()
                            .frame(maxHeight: size.height)
                            .opacity(0.00000000001)
                    }
                if shouldExpand {
                    imageView
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                do {
                                    let (data, _) = try await ImagePipeline.shared.data(for: url!)
                                    let fileType = url?.pathExtension ?? "png"
                                    let quicklook = FileManager.default.temporaryDirectory.appending(path: "quicklook.\(fileType)")
                                    if FileManager.default.fileExists(atPath: quicklook.absoluteString) {
                                        print("file exsists")
                                        try FileManager.default.removeItem(at: quicklook)
                                    }
                                    try data.write(to: quicklook)
                                    await MainActor.run {
                                        bigPicMode = quicklook
                                    }
                                } catch {
                                    print(String(describing: error))
                                }
                            }
                        }
                        .quickLookPreview($bigPicMode)
                } else {
                    imageView
                }
            } else if state.error != nil {
                // Indicates an error
                imageNotFound()
                    .frame(width: size.width, height: size.height)
                    .background(Color(uiColor: .systemGray4))
                    .foregroundColor(.secondary)
                    .cornerRadius(AppConstants.smallItemCornerRadius)
            } else {
                ProgressView() // Acts as a placeholder
                    .frame(width: size.width, height: size.height)
            }
        }
        .processors([.resize(size: size)])
        .frame(width: size.width, height: size.height)
    }
    
    func imageNotFound() -> some View {
        Image(systemName: "questionmark.square.dashed")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: AppConstants.thumbnailSize, maxHeight: AppConstants.thumbnailSize)
            .padding(AppConstants.postAndCommentSpacing)
    }
}
