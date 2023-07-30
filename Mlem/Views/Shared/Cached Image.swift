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
    let maxHeight: CGFloat

    init(url: URL?,
         shouldExpand: Bool = true,
         maxHeight: CGFloat = .infinity) {
        self.url = url
        self.shouldExpand = shouldExpand
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                let imageView = image
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: maxHeight)
                    .clipped()
                    .allowsHitTesting(false)
                    .overlay(alignment: .top) {
                        // weeps in janky hack but this lets us tap the image only in the area we want
                        Rectangle()
                            .frame(maxHeight: maxHeight)
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
                    .frame(maxWidth: .infinity, maxHeight: min(300, maxHeight))
                    .background(Color(uiColor: .systemGray4))
                    .foregroundColor(.secondary)
                    .cornerRadius(AppConstants.smallItemCornerRadius)
            } else {
                ProgressView() // Acts as a placeholder
                    .frame(maxWidth: .infinity, maxHeight: maxHeight)
            }
        }
    }
    
    func imageNotFound() -> some View {
        Image(systemName: "questionmark.square.dashed")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: AppConstants.thumbnailSize, maxHeight: AppConstants.thumbnailSize)
            .padding(AppConstants.postAndCommentSpacing)
    }
}
