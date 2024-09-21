//
//  GifImage.swift
//  Mlem
//
// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).
//
// Adapted from https://github.com/kean/NukeDemo

import Gifu
import SwiftUI

struct GifView: View {
    let data: Data
    
    var body: some View {
        // This wrapper fixes an issue where the gif doesn't work with .contextMenu
        // There's probably a slick UIKit/UIViewControllerRepresentable way to do it, but this is simple and easy
        // - Eric 2024-09-20
        GifImage(data: data)
            .overlay(Color.clear.contentShape(.rect()))
    }
}

struct GifImage: UIViewRepresentable {
    let data: Data
     
    init(data: Data) {
        self.data = data
    }

    func makeUIView(context: Context) -> GIFImageView {
        let imageView = GIFImageView()
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }

    func updateUIView(_ imageView: GIFImageView, context: Context) {
        imageView.animate(withGIFData: data, loopCount: 0)
    }

    static func dismantleUIView(_ imageView: GIFImageView, coordinator: ()) {
        imageView.prepareForReuse()
    }
}
