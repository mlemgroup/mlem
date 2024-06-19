//
//  InboxView.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import AVFoundation
import LemmyMarkdownUI
import MlemMiddleware
import NukeUI
import NukeVideo
import SwiftUI

struct InboxView: View {
    @Environment(NavigationLayer.self) var navigation

    var body: some View {
        VStack(spacing: 20) {
            TestVideoView(url: URL(string: "https://kean.github.io/videos/cat_video.mp4")!)
//            LazyImage(url: URL(string: "https://kean.github.io/videos/cat_video.mp4")) { state in
//                if let container = state.imageContainer {
//                    if let asset = container.userInfo[.videoAssetKey] as? AVAsset {
//                        TestVideoView(asset: asset)
//                        // Use `VideoPlayerView` wrapped in `UIViewRepresentable`
//                    } else {
//                        state.image // Use the default view
//                    }
//                } else {
//                    Text("sad")
//                }
//            }
            // VideoPlayerView(frame: .init())
            
            Button("Success") {
                ToastModel.main.add(.success())
            }
            Button("Failure") {
                ToastModel.main.add(.failure())
            }
            Button("Profile") {
                ToastModel.main.add(.account(AppState.main.firstSession.account))
            }
            Button("Undoable") {
                ToastModel.main.add(
                    .undoable(
                        title: "Unfavorited Community",
                        systemImage: "star.slash.fill",
                        callback: {},
                        color: .blue
                    )
                )
            }
            Button("Error") {
                handleError(ApiClientError.cancelled)
            }
            Button("Super Long Text") {
                ToastModel.main.add(.success("Really Super Long Text"))
            }
            Button("Open Sheet") {
                navigation.openSheet(.inbox)
            }
        }
    }
}
