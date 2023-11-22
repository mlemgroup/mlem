//
//  ZoomableImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-14.
//  Adapted from Ice Cubes for Mastodon: https://github.com/Dimillian/IceCubesApp
//

import Dependencies
import Foundation
import Nuke
import NukeUI
import SwiftUI

struct ZoomableImageView: View {
    @Dependency(\.notifier) var notifier
    
    let url: URL
    
    @State var quickLookUrl: URL?

    @GestureState private var zoom = 1.0

    var body: some View {
        ZoomableContainer {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
                        .scaledToFit()
                        .scaleEffect(zoom)
                        .contextMenu {
                            ForEach(genMenuFunctions(image: image)) { item in
                                MenuButton(menuFunction: item, confirmDestructive: nil)
                            }
                        }
                        .padding(.horizontal) // after context menu to avoid padding showing up in context menu
                } else if state.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
        .fullScreenCover(item: $quickLookUrl) { url in
            QuickLookView(urls: [url])
        }
    }
    
    func showQuickLook() async {
        do {
            let (data, _) = try await ImagePipeline.shared.data(for: url)
            let fileType = url.pathExtension
            let quicklook = FileManager.default.temporaryDirectory.appending(path: "quicklook.\(fileType)")
            if FileManager.default.fileExists(atPath: quicklook.absoluteString) {
                try FileManager.default.removeItem(at: quicklook)
            }
            try data.write(to: quicklook)
            quickLookUrl = quicklook
        } catch {
            print(String(describing: error))
        }
    }
    
    func saveImage() async {
        do {
            let (data, _) = try await ImagePipeline.shared.data(for: url)
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(imageData: data)
            await notifier.add(.success("Image saved"))
        } catch {
            print(String(describing: error))
        }
    }
    
    func genMenuFunctions(image: Image) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        ret.append(MenuFunction.standardMenuFunction(
            text: "Details",
            imageName: Icons.imageDetails,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await showQuickLook()
            }
        })
        
        ret.append(MenuFunction.standardMenuFunction(
            text: "Save",
            imageName: Icons.import,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await saveImage()
            }
        })
        
        ret.append(MenuFunction.shareImageFunction(image: image))
        
        return ret
    }
}
