//
//  Markdown View.swift
//  Mlem
//
//  Created by David Bureš on 18.05.2023.
//

import Foundation
import MarkdownUI
import RegexBuilder
import SwiftUI

/// Little helper struct to help with the fact that we need to handle images specially
struct MarkdownBlock: Identifiable {
    enum BlockType {
        case text(String)
        case image(url: String)
        case linkedImage(imageUrl: String, linkUrl: String)
    }
    
    let id: Int
    let type: BlockType
}

struct MarkdownView: View {
    private let text: String
    private let blocks: [MarkdownBlock]
    
    private let isNsfw: Bool
    private let replaceImagesWithEmoji: Bool
    private let isInline: Bool
    private let alignment: TextAlignment
    private let foregroundColor: Color
    
    // Don't show images from these domains
    static let hiddenImageDomains = [
        "lemmy-status.org",
        "fediseer.com",
        "uptime.lemmings.world"
    ]
    
    init(
        text: String,
        isNsfw: Bool,
        replaceImagesWithEmoji: Bool = false,
        isInline: Bool = false,
        alignment: TextAlignment = .leading,
        foregroundColor: Color = .primary
    ) {
        self.text = isInline ? MarkdownView.prepareInlineMarkdown(text: text) : text
        self.isNsfw = isNsfw
        self.replaceImagesWithEmoji = replaceImagesWithEmoji
        self.isInline = isInline
        self.alignment = alignment
        self.foregroundColor = foregroundColor
        do {
            self.blocks = try MarkdownView.parseMarkdownForImages(text: text)
        } catch {
            print("Regex error occured!")
            self.blocks = []
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(blocks) { block in
                renderBlock(block: block)
            }
        }
    }
    
    @ViewBuilder
    func renderBlock(block: MarkdownBlock) -> some View {
        switch block.type {
        case let .text(text):
            renderAsMarkdown(text: text, theme: theme)
        case let .image(url: imageUrl):
            if let imageUrl = URL(string: imageUrl) {
                imageView(url: imageUrl, blockId: block.id)
            }
        case let .linkedImage(imageUrl: imageUrl, linkUrl: linkUrl):
            if let imageUrl = URL(string: imageUrl), let linkUrl = URL(string: linkUrl) {
                Link(destination: linkUrl) {
                    imageView(url: imageUrl, blockId: block.id, shouldExpand: false)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func imageView(url: URL, blockId: Int, shouldExpand: Bool = true) -> AnyView? {
        if let host = url.host() {
            if host == "img.shields.io" {
                return AnyView(
                    BadgeView(url: url)
                        .padding(.vertical, 4)
                )
            } else if !MarkdownView.hiddenImageDomains.contains(host) {
                if replaceImagesWithEmoji {
                    return AnyView(renderAsMarkdown(
                        text: AppConstants.pictureEmoji[blockId % AppConstants.pictureEmoji.count],
                        theme: theme
                    )
                    )
                } else {
                    return AnyView(
                        CachedImage(
                            url: url,
                            shouldExpand: shouldExpand,
                            hasContextMenu: true,
                            cornerRadius: AppConstants.largeItemCornerRadius
                        )
                        .applyNsfwOverlay(isNsfw)
                    )
                }
            }
        }
        return nil
    }
    
    private var theme: Theme { isInline ? .plain : .mlem }
    
    static func prepareInlineMarkdown(text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .joined(separator: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    // This regex will capture the '![label](url "title") pattern so we can handle it separately
    // piece by piece:
    // !\[(?'label'[^\]]*)\] matches '![label]' and captures 'label' as label
    // \((?'url'[^\s\)]*) matches '(url' and captures 'url' as url
    // ( \"(?'title'[^\"]*)\")?\) matches ' "title")' or ')' and captures 'title' as title
    static let imageLooker = /!\[(?'label'[^\]]*)\]\((?'url'[^\s\)]*)( \"(?'title'[^\"]*)\")?\)/
        .ignoresCase()
    
    // Looks for images inside of links
    static let imageLinkLooker = /\[!\[(?'label'[^\]]*)\]\((?'imageURL'[^\s\)]*)( \"(?'title'[^\"]*)\")?\)\]\((?'linkURL'[^\]]*)\)/
        .ignoresCase()
    
    static func parseMarkdownForImages(text: String, blockId: Int = 0) throws -> [MarkdownBlock] {
        guard !text.isEmpty else { return [] }
        var blockId = blockId
        var blocks: [MarkdownBlock] = []
        if let firstImage = try imageLinkLooker.firstMatch(in: text) {
            if firstImage.range.lowerBound != .init(utf16Offset: 0, in: text) {
                try blocks.append(contentsOf: parseMarkdownForImages(text: String(text[..<firstImage.range.lowerBound]), blockId: blockId)
                )
                blockId += blocks.count
            }
            blocks.append(
                MarkdownBlock(
                    id: blockId,
                    type: .linkedImage(
                        imageUrl: String(firstImage.output.imageURL),
                        linkUrl: String(firstImage.output.linkURL)
                    )
                )
            )
            blockId += 1
            if firstImage.range.upperBound != .init(utf16Offset: text.count - 1, in: text) {
                try blocks.append(contentsOf: parseMarkdownForImages(text: String(text[firstImage.range.upperBound...]), blockId: blockId)
                )
            }
        } else if let firstImage = try imageLooker.firstMatch(in: text) {
            if firstImage.range.lowerBound != .init(utf16Offset: 0, in: text) {
                try blocks.append(contentsOf: parseMarkdownForImages(text: String(text[..<firstImage.range.lowerBound]), blockId: blockId)
                )
                blockId += blocks.count
            }
            blocks.append(
                MarkdownBlock(
                    id: blockId,
                    type: .image(url: String(firstImage.output.url))
                )
            )
            blockId += 1
            if firstImage.range.upperBound != .init(utf16Offset: text.count - 1, in: text) {
                try blocks.append(contentsOf: parseMarkdownForImages(text: String(text[firstImage.range.upperBound...]), blockId: blockId)
                )
            }
        } else if !text.isEmpty {
            blocks.append(MarkdownBlock(id: blockId, type: .text(String(text))))
        }
        return blocks
    }

    func renderAsMarkdown(text: String, theme: Theme = .mlem) -> some View {
        Markdown(text)
            .markdownTextStyle(\.text) {
                ForegroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .top : .topLeading)
            .multilineTextAlignment(alignment)
            .markdownTheme(theme)
    }
}
