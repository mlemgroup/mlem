//
//  CoreMediaViewer.swift
//  Mlem
//
//  Created by tht7 on 27/07/2023.
//

import Foundation
import SwiftUI
import UIKit
import Nuke
import NukeVideo
import NukeUI
import SwiftyGif
import AVKit
import Combine
import LinkPresentation

let testImage = URL(string: "https://user-images.githubusercontent.com/1567433/114792417-57c1d080-9d56-11eb-8035-dc07cfd7557f.png")!

struct CoreMediaViewer<ErrorView: View>: UIViewRepresentable, Identifiable {
    var url: URL?
    var id: Int { url?.hashValue ?? UUID().hashValue }
    
    @ObservedObject
    var mediaStateSyncObject: MediaState
    let needsMediaSync: Bool
    
    @ViewBuilder
    let errorView: (_ error: Error) -> ErrorView
    
    let onImageLoad: ((_ container: Nuke.ImageContainer, _ size: CGSize) -> Void)?
    
    @State var mediaSize: CGSize = .zero
    
    init(
        url: URL? = nil,
        mediaStateSyncObject: MediaState? = nil,
        @ViewBuilder errorView: @escaping (_: Error?) -> ErrorView,
        onImageLoad: ((_: Nuke.ImageContainer, _ size: CGSize) -> Void)? = nil
    ) {
        _mediaStateSyncObject = .init(wrappedValue: mediaStateSyncObject ?? .init())
        self.needsMediaSync = mediaStateSyncObject != nil
        
        self.url = url
        self.errorView = errorView
        self.onImageLoad = onImageLoad
    }

    @MainActor func makeUIView(context: Context) -> LazyImageView {
        context.coordinator.imageView.placeholderView = UIActivityIndicatorView()
        context.coordinator.imageView.failureView = context.coordinator.errorView.view
        context.coordinator.imageView.onFailure = { error in
            context.coordinator.errorView.rootView = AnyView(errorView(error))
        }
        
        context.coordinator.imageView.clipsToBounds = true
        context.coordinator.imageView.translatesAutoresizingMaskIntoConstraints = true
        context.coordinator.imageView.makeImageView = context.coordinator.makeImage
        context.coordinator.imageView.setNeedsLayout()
        context.coordinator.imageView.invalidateIntrinsicContentSize()
        context.coordinator.imageView.url = url
        return context.coordinator.imageView
    }
    
    func updateUIView(_ uiView: LazyImageView, context: Context) {
        if uiView.url != url {
            context.coordinator.resetValues()
            uiView.url = url
            uiView.setNeedsLayout()
            uiView.invalidateIntrinsicContentSize()
        }
        if needsMediaSync && !context.coordinator.wasReady && mediaStateSyncObject.isReady {
            let menu = context.coordinator.generateContextMenu()
            context.environment.fullscreenContextMenuDonationCollector(menu)
            context.coordinator.wasReady = true
        }
    }
    
    @MainActor
    func getImageSize(imageView: LazyImageView, context: Self.Context) -> CGSize? {
        if context.coordinator.mediaSize != .zero {
            return context.coordinator.mediaSize
        }
//        if let image = self.shareableImage,
//           image.size != .zero {
//            return image.size
//        }
        
        if let view = imageView.subviews.last {
            let viewSize = view.bounds.size
            if viewSize.width > 0 ||
                viewSize.height > 0 {
                return viewSize
            }
        }
        
        return nil
    }
    
    @MainActor 
    func sizeThatFits(_ proposal: ProposedViewSize,
                      uiView: Self.UIViewType,
                      context: Self.Context
    ) -> CGSize? {
        guard 
        let imageSize = getImageSize(imageView: uiView, context: context)
        else {
            return nil
        }
        
        if let propsedWidth = proposal.width {
            if propsedWidth != 0 {
                let ratio = propsedWidth / imageSize.width
                let neededHeight = imageSize.height * ratio
                if neededHeight == 0 {
                    // hmmm weird, thanks UIKit!
                    return nil
                }
                return CGSize(width: propsedWidth, height: neededHeight)
            } else {
                return imageSize
            }
        } else { return imageSize }
    }
    
    func makeCoordinator() -> MediaCoordinator<ErrorView> {
        MediaCoordinator(
            parent: self,
            onImageLoad: onImageLoad
        )
    }
    
    @MainActor
    static func dismantleUIView(_ uiView: LazyImageView, coordinator: MediaCoordinator<ErrorView>) {
        uiView.reset()
        coordinator.resetValues()
    }
}

#if DEBUG
let testImageURLs = [
    "https://lemm.ee/pictrs/image/afe866cc-284f-435e-b76e-ff7cef2ed14c.webp",
    "https://user-images.githubusercontent.com/1567433/114792417-57c1d080-9d56-11eb-8035-dc07cfd7557f.png",
    "https://media4.giphy.com/media/cawXwjEwhuFfXafQw2/giphy.gif",
    "https://www.w3schools.com/html/mov_bbb.mp4",
    "https://kean.github.io/videos/cat_video.mp4",
    "https://www.youtube.com/embed/Zbkil4kutwI"
].map { str in URL(string: str)! }
struct CoreMediaViewerPreview: PreviewProvider {
    @StateObject static var mediaState = MediaState()
    
    static var previews: some View {
        ForEach(testImageURLs) { testURL in
            VStack {
//                Spacer()
//                AsyncImage(url: testURL) { state in
//                    if let image = state.image {
//                        image.resizable().scaledToFit()
//                    }
//                }
                CoreMediaViewer(url: testURL, mediaStateSyncObject: mediaState) { error in
                    Image(systemName: "pencil.slash")
                    if let error = error {
                        Text(String(describing: error))
                    }
                }

//                Spacer()
            }
            .scaledToFit()
//            .frame(maxHeight: 400, alignment: .center)
            .background(.blue)
            .previewDisplayName(testURL.pathExtension.capitalized)
        }.onAppear {
            ImageDecoderRegistry.shared.register { context in ImageDecoders.Video(context: context) }
        }
    }
}
#endif
