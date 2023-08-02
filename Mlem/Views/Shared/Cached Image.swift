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
    @State var size: CGSize
    
    let postView: APIPostView?

    init(url: URL?,
         shouldExpand: Bool = true,
         maxHeight: CGFloat = .infinity,
         postView: APIPostView? = nil) {
        self.url = url
        self.shouldExpand = shouldExpand
        self.maxHeight = maxHeight
        self.postView = postView
        self._size = State(initialValue: postView?.size ?? CGSize(width: 1, height: 1))
        
        if let url {
            let testImage = ImagePipeline.shared.cache[url]
            print(testImage?.image.size)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            LazyImage(url: url) { state in
                if let image = state.imageContainer {
                    let imageView = Image(uiImage: image.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: min(size.height, maxHeight))
                        .clipped()
                        .allowsHitTesting(false)
                        .overlay(alignment: .top) {
                            // weeps in janky hack but this lets us tap the image only in the area we want
                            Rectangle()
                                .frame(maxHeight: min(size.height, maxHeight))
                                .opacity(0.00000000001)
                        }
                        .onAppear {
                            if let postView {
                                // print("\(postView.id) appeared")
                                
                                let ratio = geo.size.width / image.image.size.width
                                
                                // print(ratio)
                                
                                let newSize = CGSize(width: geo.size.width,
                                                     height: image.image.size.height * ratio)
                                size = newSize
                                postView.setSize(newSize: newSize)
                            }
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
                        .frame(width: size.width, height: min(size.height, maxHeight))
                }
            }
            .processors([.resize(size: size)])
            .frame(width: size.width, height: min(size.height, maxHeight))
        }
        .frame(maxWidth: .infinity)
        .frame(height: min(size.height, maxHeight))
    }
    
    func imageNotFound() -> some View {
        Image(systemName: "questionmark.square.dashed")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: AppConstants.thumbnailSize, maxHeight: AppConstants.thumbnailSize)
            .padding(AppConstants.postAndCommentSpacing)
    }
}
