//
//  VideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-23.
//

import AVFoundation
import Foundation
import Gifu
import Nuke
import NukeUI
import NukeVideo
import SwiftUI

struct NukeGifView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> some UIView {
        let imageView = GIFImageView()
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.animate(withGIFData: data, loopCount: 0)
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // noop
    }
}

struct VideoView: UIViewRepresentable {
    let asset: AVAsset
    
    func makeUIView(context: Context) -> some UIView {
        let view = VideoPlayerView()
        view.asset = asset
        view.videoGravity = .resizeAspect
        view.play()
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // noop
    }
}
