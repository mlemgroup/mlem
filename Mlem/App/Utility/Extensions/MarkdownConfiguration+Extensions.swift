//
//  MarkdownConfiguration+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import LemmyMarkdownUI
import Nuke
import SwiftUI

extension MarkdownConfiguration {
    static let `default`: Self = .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: { AnyView(MarkdownImageView(image: $0)) }
    )
}

private func loadInlineImage(inlineImage: InlineImage) async {
    guard inlineImage.image == nil else { return }
    let imageTask = ImagePipeline.shared.imageTask(with: inlineImage.url)
    guard let image: UIImage = try? await imageTask.image else { return }
    let height = inlineImage.fontSize
    let width = image.size.width * (height / image.size.height)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2.0)
    defer { UIGraphicsEndImageContext() }
    image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    if let newImage {
        DispatchQueue.main.async {
            inlineImage.image = Image(uiImage: newImage)
        }
    }
}
