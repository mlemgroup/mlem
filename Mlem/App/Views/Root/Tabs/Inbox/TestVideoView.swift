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

// struct TestVideoView: View {
struct TestVideoView: UIViewRepresentable {
    // let asset: AVAsset
    let url: URL
    
    func makeUIView(context: Context) -> some UIView {
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
        
        print("in init: \(url.description)")
        let imageView = LazyImageView()
        imageView.makeImageView = { container in
            if let type = container.type, type.isVideo, let asset = container.userInfo[.videoAssetKey] as? AVAsset {
                let view = VideoPlayerView()
                view.asset = asset
                view.play()
                print("that's a view!")
                return view
            }
            print("nah fam")
            return nil
        }
        imageView.url = url
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let imageView = uiView as? LazyImageView {
            print("updating?")
            print(url)
            Task { @MainActor in
                imageView.url = url
            }
        }
        // noop
    }
}
