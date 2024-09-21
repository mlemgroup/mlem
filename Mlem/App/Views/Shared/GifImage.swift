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

// public struct GifImage: View {
//     private let data: Data
//     private var loopCount = 0
//     private var isResizable = false
//
//     /// Initialzies the view with the given data
//     public init(_ data: Data) {
//         self.data = data
//     }
//
//     /// Sets the desired number of loops. By default, the number of loops infinite.
//     public func loopCount(_ value: Int) -> GifImage {
//         var copy = self
//         copy.loopCount = value
//         return copy
//     }
//
//     /// Sets an image to fit its space.
//     public func resizable() -> GifImage {
//         var copy = self
//         copy.isResizable = true
//         return copy
//     }
//
//     public var body: some View {
//         _GifImage(data: data, loopCount: loopCount, isResizable: isResizable)
//     }
// }

struct GifImage: UIViewRepresentable {
    let data: Data
    let loopCount: Int
    let isResizable: Bool
     
    init(
        data: Data,
        loopCount: Int = 0,
        resizable: Bool = true
    ) {
        self.data = data
        self.loopCount = loopCount
        self.isResizable = resizable
    }

    func makeUIView(context: Context) -> GIFImageView {
        let imageView = GIFImageView()
        if isResizable {
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        }
        return imageView
    }

    func updateUIView(_ imageView: GIFImageView, context: Context) {
        imageView.animate(withGIFData: data, loopCount: loopCount)
    }

    static func dismantleUIView(_ imageView: GIFImageView, coordinator: ()) {
        imageView.prepareForReuse()
    }
}
