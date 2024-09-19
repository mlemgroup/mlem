//
//  VideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-18.
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
//                if url.pathExtension.lowercased() == "gif" {
//                    let view = FLAnimatedImageView()
//                    Nuke.loadImage(with: URL(string: "http://.../cat.gif")!, into: view)
//                }
                
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

// ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
//
// extension Gifu.GIFImageView {
//    public override func nuke_display(image: Image?) {
//        prepareForReuse()
//        if let data = image?.animatedImageData {
//            animate(withGIFData: data)
//        } else {
//            self.image = image
//        }
//    }
// }
