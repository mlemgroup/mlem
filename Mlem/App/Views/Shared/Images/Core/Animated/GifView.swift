//
//  GifView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-27.
//

import Gifu
import SwiftUI

struct GifView: View {
    let data: Data
    
    var body: some View {
        UIGifView(data: data)
            .allowsHitTesting(false)
            .overlay {
                Color.clear.contentShape(.rect)
            }
    }
}

private struct UIGifView: UIViewRepresentable {
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
