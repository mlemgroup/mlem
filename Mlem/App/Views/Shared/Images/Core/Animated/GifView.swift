//
//  GifView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-27.
//

import Gifu
import SwiftUI

struct GifView: View {
    @Environment(MediaControlState.self) var controlState
    
    let data: Data
    
    var body: some View {
        UIGifView(data: data, animating: controlState.animating)
            .withAnimationControls()
    }
}

private struct UIGifView: UIViewRepresentable {
    let data: Data
    let animating: Bool
    
    func makeUIView(context: Context) -> GIFImageView {
        let imageView = GIFImageView()
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.prepareForAnimation(withGIFData: data)
        return imageView
    }
    
    func updateUIView(_ uiView: GIFImageView, context: Context) {
        if animating {
            uiView.startAnimatingGIF()
        } else {
            uiView.stopAnimatingGIF()
        }
    }
}
