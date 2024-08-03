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
    static let defaultBlurred: Self = .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: {
            imageView($0, blurred: true)
        },
        primaryColor: Palette.main.primary,
        secondaryColor: Palette.main.secondary
    )
    
    static let `default`: Self = .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: { imageView($0, blurred: false) },
        primaryColor: Palette.main.primary,
        secondaryColor: Palette.main.secondary
    )
    
    static let dimmed: Self = .init(
        inlineImageLoader: { _ in },
        imageBlockView: { imageView($0, blurred: false) },
        primaryColor: Palette.main.secondary,
        secondaryColor: Palette.main.tertiary
    )
    
    static let caption: Self = .init(
        inlineImageLoader: { _ in },
        imageBlockView: { imageView($0, blurred: false) },
        primaryColor: Palette.main.secondary,
        secondaryColor: Palette.main.tertiary,
        font: .caption1
    )
}

private func imageView(_ inlineImage: InlineImage, blurred: Bool) -> AnyView {
    AnyView(
        LargeImageView(url: inlineImage.url, blurred: blurred)
            .aspectRatio(CGSize(width: 1, height: 1.2), contentMode: .fill)
            .frame(maxWidth: .infinity)
    )
}

private func loadInlineImage(inlineImage: InlineImage) async {
    // Only custom emojis should be displayed inline. Custom emojis have tooltips.
    // People are unlikely to use tooltips in any other circumstances, so images
    // with tooltips are displayed inline. I haven't found a better way to test for
    // a custom emoji.
    if inlineImage.tooltip == nil {
        inlineImage.renderFullWidth = true
        return
    }
    
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
