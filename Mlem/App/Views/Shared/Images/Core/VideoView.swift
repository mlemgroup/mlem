//
//  VideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-23.
//

import AVFoundation
import Foundation
import Nuke
import NukeUI
import NukeVideo
import SwiftUI

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
