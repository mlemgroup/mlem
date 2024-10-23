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
    static var defaultBlurred: MarkdownConfiguration { .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: {
            imageView($0, shouldBlur: true)
        },
        wrapCodeBlockLines: Settings.main.wrapCodeBlockLines,
        primaryColor: Palette.main.primary,
        secondaryColor: Palette.main.secondary,
        codeBackgroundColor: Palette.main.tertiaryGroupedBackground,
        codeFontScaleFactor: 0.9
    ) }
    
    static var `default`: MarkdownConfiguration { .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: { imageView($0, shouldBlur: false) },
        wrapCodeBlockLines: Settings.main.wrapCodeBlockLines,
        primaryColor: Palette.main.primary,
        secondaryColor: Palette.main.secondary,
        codeBackgroundColor: Palette.main.tertiaryGroupedBackground,
        codeFontScaleFactor: 0.9
    ) }
    
    static var dimmed: MarkdownConfiguration { .init(
        inlineImageLoader: { _ in },
        imageBlockView: { imageView($0, shouldBlur: false) },
        wrapCodeBlockLines: Settings.main.wrapCodeBlockLines,
        primaryColor: Palette.main.secondary,
        secondaryColor: Palette.main.tertiary,
        codeBackgroundColor: Palette.main.tertiaryGroupedBackground,
        codeFontScaleFactor: 0.9
    ) }
    
    static var caption: MarkdownConfiguration { .init(
        inlineImageLoader: { _ in },
        imageBlockView: { imageView($0, shouldBlur: false) },
        wrapCodeBlockLines: Settings.main.wrapCodeBlockLines,
        primaryColor: Palette.main.primary,
        secondaryColor: Palette.main.secondary,
        codeBackgroundColor: Palette.main.tertiaryGroupedBackground,
        font: .caption1,
        codeFontScaleFactor: 0.9
    ) }
}

private func imageView(_ inlineImage: InlineImage, shouldBlur: Bool) -> AnyView {
    AnyView(
        LargeImageView(url: inlineImage.url, shouldBlur: shouldBlur)
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
        Task { @MainActor in
            inlineImage.renderFullWidth = true
        }
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
