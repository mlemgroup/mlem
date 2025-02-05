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
        imagePresentationMode: .inline,
        inlineImageLoader: { _ in }, // Don't load inline images; they will remain as placeholders
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
    
    static var inverted: MarkdownConfiguration { .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: { imageView($0, shouldBlur: false) },
        wrapCodeBlockLines: Settings.main.wrapCodeBlockLines,
        primaryColor: Palette.main.selectedInteractionBarItem,
        secondaryColor: Palette.main.selectedInteractionBarItem.opacity(0.8),
        spoilerHeaderBackgroundColor: Palette.main.selectedInteractionBarItem.opacity(0.1),
        spoilerOutlineColor: Palette.main.selectedInteractionBarItem.opacity(0.5),
        codeBackgroundColor: Palette.main.selectedInteractionBarItem.opacity(0.1),
        codeFontScaleFactor: 0.9
    ) }
}

private func imageView(_ image: MarkdownImage, shouldBlur: Bool) -> AnyView {
    if image.url.absoluteString == "https://ko-fi.com/img/githubbutton_sm.svg" {
        return AnyView(ShieldsBadgeView(label: "KoFi", message: nil, link: image.parentLink))
    }
    switch image.url.host() {
    case "img.shields.io":
        return AnyView(ShieldsBadgeView(shieldsUrl: image.url, link: image.parentLink))
    case "fediseer.com":
        return AnyView(ShieldsBadgeView(label: "Fediseer", message: nil, link: image.parentLink))
    case "lemmy-status.org":
        return AnyView(ShieldsBadgeView(label: .init(localized: "Uptime"), message: nil, link: image.parentLink))
    default:
        return AnyView(
            MediaView(
                url: image.url,
                verticalAspectRatioBounds: .init(width: 4, height: 5),
                cornerRadius: Constants.main.mediumItemCornerRadius,
                enableContextMenu: true,
                enableImageViewer: true,
                enableNsfwBlur: shouldBlur
            )
        )
    }
}

private func loadInlineImage(inlineImage: MarkdownImage) async {
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
