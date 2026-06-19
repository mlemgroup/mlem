//
//  MarkdownConfiguration+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import Nuke
import SwiftUI
import Theming

enum MarkdownConfigurationType {
    case `default`, defaultBlurred, dimmed, caption, inverted, removedContent
}

extension MarkdownConfiguration {
    init(type: MarkdownConfigurationType, palette: Palette) {
        self = switch type {
        case .default: .default(palette: palette)
        case .defaultBlurred: .defaultBlurred(palette: palette)
        case .dimmed: .dimmed(palette: palette)
        case .caption: .caption(palette: palette)
        case .inverted: .inverted(palette: palette)
        case .removedContent: .removedContent(palette: palette)
        }
    }
    
    static func `default`(palette: Palette) -> MarkdownConfiguration {
        let currentPaletteOption = Settings.get(\.appearance_palette)
        let enableSyntaxHighlighting = ![.solarized, .monochrome].contains(currentPaletteOption)

        return .init(
            inlineImageLoader: loadInlineImage,
            imageBlockView: { imageView($0, shouldBlur: false) },
            wrapCodeBlockLines: Settings.get(\.markdown_wrapCodeBlockLines),
            spoilerLabel: .init(localized: "Spoiler"),
            tableLabel: .init(localized: "Table"),
            censorLabel: .init(localized: "Censored"),
            primaryColor: palette.label.primary,
            secondaryColor: palette.label.secondary,
            codeBackgroundColor: palette.groupedBackground.tertiary,
            censorColor: palette.warning,
            codeFontScaleFactor: 0.9,
            enableSyntaxHighlighting: enableSyntaxHighlighting
        )
    }
    
    static func defaultBlurred(palette: Palette) -> MarkdownConfiguration {
        var config = Self.default(palette: palette)
        config.imageBlockView = { imageView($0, shouldBlur: true) }
        return config
    }
    
    static func dimmed(palette: Palette) -> MarkdownConfiguration {
        var config = Self.default(palette: palette)
        
        // Don't load any images; they will remain as placeholders
        config.imagePresentationMode = .inline
        config.inlineImageLoader = { _ in }
        
        config.primaryColor = palette.label.secondary
        config.secondaryColor = palette.label.tertiary
        
        return config
    }
    
    static func caption(palette: Palette) -> MarkdownConfiguration {
        var config = Self.default(palette: palette)
        config.font = .preferredFont(forTextStyle: .caption1)
        return config
    }
    
    static func inverted(palette: Palette) -> MarkdownConfiguration {
        var config = Self.default(palette: palette)
        config.primaryColor = palette.contrastingLabel
        config.secondaryColor = palette.contrastingLabel.opacity(0.8)
        config.spoilerHeaderBackgroundColor = palette.contrastingLabel.opacity(0.1)
        config.spoilerOutlineColor = palette.contrastingLabel.opacity(0.5)
        config.codeBackgroundColor = palette.contrastingLabel.opacity(0.1)
        return config
    }
    
    static func removedContent(palette: Palette) -> MarkdownConfiguration {
        var config = Self.default(palette: palette)
        config.primaryColor = palette.negative
        config.secondaryColor = palette.negative.opacity(0.8)
        config.spoilerHeaderBackgroundColor = palette.negative.opacity(0.1)
        config.spoilerOutlineColor = palette.negative.opacity(0.5)
        config.codeBackgroundColor = palette.negative.opacity(0.1)
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
            MediaView.largeImage(url: image.url, shouldBlur: shouldBlur)
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
