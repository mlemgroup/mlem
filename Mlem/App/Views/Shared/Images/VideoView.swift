//
//  TestVideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-19.
//

import AVFoundation
import Foundation
import Gifu
import Nuke
import NukeUI
import NukeVideo
import SDWebImageSwiftUI
import SwiftUI

struct TestVideoView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> some UIView {
        let imageView = LazyImageView()
        imageView.makeImageView = { container in
            if let type = container.type {
                if type.isVideo, let asset = container.userInfo[.videoAssetKey] as? AVAsset {
                    let view = VideoPlayerView()
                    view.asset = asset
                    view.play()
                    return view
                }
                
                if type == .gif, let data = container.data {
                    let imageView = GIFImageView()
                    imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                    imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                    imageView.animate(withGIFData: data, loopCount: 0)
                    return imageView
                }
                
                if type == .webp, let data = container.data {
                    // if type == .webp {
                    let imageView = UIImageView()
                    // imageView.sd_setImage(with: url)
                    // imageView.sd_data
                    let image = SDImageAWebPCoder().decodedImage(with: data)
                    
                    imageView.image = image
                    return imageView
                }
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
