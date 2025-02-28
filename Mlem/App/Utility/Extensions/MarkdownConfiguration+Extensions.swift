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
    static var `default`: MarkdownConfiguration { .init(
        inlineImageLoader: loadInlineImage,
        imageBlockView: { imageView($0, shouldBlur: false) },
        wrapCodeBlockLines: Settings.main.wrapCodeBlockLines,
        spoilerLabel: .init(localized: "Spoiler"),
        tableLabel: .init(localized: "Table"),
        censorLabel: .init(localized: "Censored"),
        primaryColor: Palette.main.primary,
        secondaryColor: Palette.main.secondary,
        codeBackgroundColor: Palette.main.tertiaryGroupedBackground,
        censorColor: Palette.main.warning,
        codeFontScaleFactor: 0.9
    ) }
    
    static var defaultBlurred: MarkdownConfiguration {
        var config = Self.default
        config.imageBlockView = { imageView($0, shouldBlur: true) }
        return config
    }
    
    static var dimmed: MarkdownConfiguration {
        var config = Self.default
        
        // Don't load any images; they will remain as placeholders
        config.imagePresentationMode = .inline
        config.inlineImageLoader = { _ in }
        
        config.primaryColor = Palette.main.secondary
        config.secondaryColor = Palette.main.tertiary
        
        return config
    }
    
    static var caption: MarkdownConfiguration {
        var config = Self.default
        config.font = .preferredFont(forTextStyle: .caption1)
        return config
    }
    
    static var inverted: MarkdownConfiguration {
        var config = Self.default
        config.primaryColor = Palette.main.selectedInteractionBarItem
        config.secondaryColor = Palette.main.selectedInteractionBarItem.opacity(0.8)
        config.spoilerHeaderBackgroundColor = Palette.main.selectedInteractionBarItem.opacity(0.1)
        config.spoilerOutlineColor = Palette.main.selectedInteractionBarItem.opacity(0.5)
        config.codeBackgroundColor = Palette.main.selectedInteractionBarItem.opacity(0.1)
        return config
    }
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
    Task { @MainActor in
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        inlineImage.image = Image(uiImage: newImage)
    }
}
