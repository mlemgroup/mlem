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

    init(url: URL?, shouldExpand: Bool = true) {
        self.url = url
        self.shouldExpand = shouldExpand
    }
    
    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                let imageView = image
                    .resizable()
                    .scaledToFill()
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
                Color.red
                    .frame(minWidth: 300, minHeight: 300)
                    .blur(radius: 30)
                    .overlay(VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text("Error")
                            .fontWeight(.black)
                    }
                    .foregroundColor(.white)
                    .padding(8))
            } else {
                ProgressView() // Acts as a placeholder
                    .frame(minWidth: 300, minHeight: 300)
            }
        }
    }
}
