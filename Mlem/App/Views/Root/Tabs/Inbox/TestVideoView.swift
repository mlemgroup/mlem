//
//  TestVideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-19.
//

import AVFoundation
import Foundation
import Nuke
import NukeUI
import NukeVideo
import SwiftUI

struct TestVideoView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> some UIView {
        let imageView = LazyImageView()
        imageView.makeImageView = { container in
            if let type = container.type, type.isVideo, let asset = container.userInfo[.videoAssetKey] as? AVAsset {
                let view = VideoPlayerView()
                view.asset = asset
                view.play()
                return view
            }
            return nil
        }
        imageView.url = url
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // noop
    }
}
