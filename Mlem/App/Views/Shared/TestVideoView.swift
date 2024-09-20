//
//  TestVideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-19.
//

import AVFoundation
import Foundation
import Gifu
import Nuke
import NukeExtensions
import NukeUI
import NukeVideo
import SwiftUI

// A custom image view that supports downloading and displaying animated images.
// final class ImageView: UIView {
//    private let imageView: GIFImageView
//    private let spinner: UIActivityIndicatorView
//    private var task: ImageTask?
//
//    /* Initializers skipped */
//
//    func setImage(with url: URL) {
//        prepareForReuse()
//
//        if let response = ImagePipeline.shared.cache[url] {
//            imageView.display(response: response)
//            if !response.isPreview {
//                return
//            }
//        }
//
//        spinner.startAnimating()
//        task = ImagePipeline.shared.loadImage(with: url) { [weak self] result in
//            self?.spinner.stopAnimating()
//            if case let .success(response) = result {
//                self?.imageView.display(response: response)
//            }
//        }
//    }
//
//    private func display(response: ImageResponse) {
//        if let data = response.container.data {
//            animate(withGIFData: data)
//        } else {
//            image = response.image
//        }
//    }
//
//    private func prepareForReuse() {
//        task?.cancel()
//        spinner.stopAnimating()
//        imageView.prepareForReuse()
//    }
// }

struct TestVideoView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> some UIView {
        let imageView = LazyImageView()
        imageView.makeImageView = { container in
            if let type = container.type {
                if type == .gif, let data = container.data {
                    print("It's a gif!")
                    let view = GIFImageView()
                    view.animate(withGIFData: data)
                    return view
                } else {
                    let view = UITextView()
                    view.text = "Type is \(type.rawValue)"
                    return view
                }
            } else {
                let view = UITextView()
                view.text = "No container"
                return view
            }
        }
        
        // imageView.url = url
        return imageView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // noop
    }
}

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
