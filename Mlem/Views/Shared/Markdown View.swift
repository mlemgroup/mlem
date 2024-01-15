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

// swiftlint:disable file_length

extension Theme {
    static let mlem = Theme()
        .text {
            ForegroundColor(.text)
            BackgroundColor(.clear)
            FontSize(16)
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            BackgroundColor(.secondaryBackground)
        }
        .strong {
            FontWeight(.semibold)
        }
        .link {
            ForegroundColor(.link)
        }
        .heading1 { configuration in
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                    .relativePadding(.bottom, length: .em(0.3))
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(2))
                    }
                Divider().overlay(Color.divider)
            }
        }
        .heading2 { configuration in
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                    .relativePadding(.bottom, length: .em(0.3))
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1.5))
                    }
                Divider().overlay(Color.divider)
            }
        }
        .heading3 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.125))
                .markdownMargin(top: 24, bottom: 16)
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(1.25))
                }
        }
        .heading4 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.125))
                .markdownMargin(top: 24, bottom: 16)
                .markdownTextStyle {
                    FontWeight(.semibold)
                }
        }
        .heading5 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.125))
                .markdownMargin(top: 24, bottom: 16)
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(0.875))
                }
        }
        .heading6 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.125))
                .markdownMargin(top: 24, bottom: 16)
                .markdownTextStyle {
                    FontWeight(.semibold)
                    FontSize(.em(0.85))
                    ForegroundColor(.tertiaryText)
                }
        }
        .paragraph { configuration in
            configuration.label
                .fixedSize(horizontal: false, vertical: true)
                .relativeLineSpacing(.em(0.25))
                .markdownMargin(top: 0, bottom: 16)
        }
        .blockquote { configuration in
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.border)
                    .relativeFrame(width: .em(0.2))
                configuration.label
                    .markdownTextStyle { ForegroundColor(.secondaryText) }
                    .relativePadding(.horizontal, length: .em(1))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .codeBlock { configuration in
            ScrollView(.horizontal) {
                configuration.label
                    .relativeLineSpacing(.em(0.225))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding(16)
            }
            .background(Color.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .markdownMargin(top: 0, bottom: 16)
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: .em(0.25))
        }
        .taskListMarker { configuration in
            Image(systemName: configuration.isCompleted ? Icons.successSquareFill : Icons.emptySquare)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.checkbox, Color.checkboxBackground)
                .imageScale(.small)
                .relativeFrame(minWidth: .em(1.5), alignment: .trailing)
        }
        .table { configuration in
            ScrollView([.horizontal]) {
                configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .markdownTableBorderStyle(.init(color: .border))
                    .markdownTableBackgroundStyle(
                        .alternatingRows(Color.background, Color.secondaryBackground)
                    )
                    .markdownMargin(top: 0, bottom: 16)
            }
        }
        .tableCell { configuration in
            configuration.label
                .markdownTextStyle {
                    if configuration.row == 0 {
                        FontWeight(.semibold)
                    }
                    BackgroundColor(nil)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 6)
                .padding(.horizontal, 13)
                .relativeLineSpacing(.em(0.25))
        }
        .thematicBreak {
            Divider()
                .relativeFrame(height: .em(0.25))
                .overlay(Color.border)
                .markdownMargin(top: 24, bottom: 24)
        }
        .image { image in
            image.label
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous))
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .stroke(Color(.secondarySystemBackground), lineWidth: 1.5)
                )
        }
    
    static let plain = Theme()
        .link {
            ForegroundColor(.link)
        }
        .text {
            ForegroundColor(.secondary)
            FontSize(16)
        }
        .code {}
}

private extension Color {
    static let text = Color(
        light: Color(rgba: 0x0606_06FF), dark: Color(rgba: 0xFBFB_FCFF)
    )
    static let secondaryText = Color(
        light: Color(rgba: 0x6B6E_7BFF), dark: Color(rgba: 0x9294_A0FF)
    )
    static let tertiaryText = Color(
        light: Color(rgba: 0x6B6E_7BFF), dark: Color(rgba: 0x6D70_7DFF)
    )
    static let background = Color(
        light: .white, dark: Color(rgba: 0x1819_1DFF)
    )
    static let secondaryBackground = Color(
        light: Color(rgba: 0xF7F7_F9FF), dark: Color(rgba: 0x2526_2AFF)
    )
    static let link = Color(
        light: Color(rgba: 0x2C65_CFFF), dark: Color(rgba: 0x4C8E_F8FF)
    )
    static let border = Color(
        light: Color(rgba: 0xE4E4_E8FF), dark: Color(rgba: 0x4244_4EFF)
    )
    static let divider = Color(
        light: Color(rgba: 0xD0D0_D3FF), dark: Color(rgba: 0x3334_38FF)
    )
    static let checkbox = Color(rgba: 0xB9B9_BBFF)
    static let checkboxBackground = Color(rgba: 0xEEEE_EFFF)
}

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
        alignment: TextAlignment = .leading
    ) {
        self.text = isInline ? MarkdownView.prepareInlineMarkdown(text: text) : text
        self.isNsfw = isNsfw
        self.replaceImagesWithEmoji = replaceImagesWithEmoji
        self.isInline = isInline
        self.alignment = alignment
        self.blocks = MarkdownView.parseMarkdownForImages(text: text)
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
        case .text(let text):
            renderAsMarkdown(text: text, theme: theme)
        case .image(url: let imageUrl):
            if replaceImagesWithEmoji {
                renderAsMarkdown(text: AppConstants.pictureEmoji.randomElement() ?? "🖼️", theme: theme)
            } else {
                if let imageUrl = URL(string: imageUrl) {
                    imageView(url: imageUrl)
                }
            }
        case .linkedImage(imageUrl: let imageUrl, linkUrl: let linkUrl):
            if let imageUrl = URL(string: imageUrl), let linkUrl = URL(string: linkUrl) {
                Link(destination: linkUrl) {
                    imageView(url: imageUrl)
                }
            }
        }
    }
    
    func imageView(url: URL) -> AnyView? {
        if let host = url.host() {
            if host == "img.shields.io" {
                return AnyView(
                    BadgeView(url: url)
                        .padding(.vertical, 6)
                    )
            } else if !MarkdownView.hiddenImageDomains.contains(host) {
                return AnyView(
                    CachedImage(url: url)
                        .applyNsfwOverlay(isNsfw)
                    )
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
    
    // swiftlint:disable:next function_body_length
    static func parseMarkdownForImages(text: String) -> [MarkdownBlock] {
        // this regex will capture the '![label](url "title") pattern so we can handle it separately
        // piece by piece:
        // !\[(?'label'[^\]]*)\] matches '![label]' and captures 'label' as label
        // \((?'url'[^\s\)]*) matches '(url' and captures 'url' as url
        // ( \"(?'title'[^\"]*)\")?\) matches ' "title")' or ')' and captures 'title' as title
        let imageLooker = /!\[(?'label'[^\]]*)\]\((?'url'[^\s\)]*)( \"(?'title'[^\"]*)\")?\)/
            .ignoresCase()
        
        // Looks for images inside of links
        let imageLinkLooker = /\[!\[(?'label'[^\]]*)\]\((?'imageURL'[^\s\)]*)( \"(?'title'[^\"]*)\")?\)\]\((?'linkURL'[^\]]*)\)/
            .ignoresCase()
 
        var blocks: [MarkdownBlock] = .init()
        var idx: String.Index = .init(utf16Offset: 0, in: text)
        var blockId = 0
        while idx < text.endIndex {
            do {
                if let firstImage = try imageLinkLooker.firstMatch(in: text[idx...]) {
                    // if there is some image found, add it to blocks
                    print("LINKED IMAGE", firstImage.output.imageURL, firstImage.output.linkURL)
                    if firstImage.range.lowerBound == idx {
                        // if the regex starts *right here*, add to images
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
                    } else {
                        // otherwise, add text in between, then first match
                        blocks.append(MarkdownBlock(id: blockId, type: .text(String(text[idx ..< firstImage.range.lowerBound]))))
                        blockId += 1
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
                    }
                    idx = firstImage.range.upperBound
                } else if let firstImage = try imageLooker.firstMatch(in: text[idx...]) {
                    // if there is some image found, add it to blocks
                    if firstImage.range.lowerBound == idx {
                        // if the regex starts *right here*, add to images
                        blocks.append(MarkdownBlock(id: blockId, type: .image(url: String(firstImage.output.url))))
                        blockId += 1
                    } else {
                        // otherwise, add text in between, then first match
                        blocks.append(MarkdownBlock(id: blockId, type: .text(String(text[idx ..< firstImage.range.lowerBound]))))
                        blockId += 1
                        blocks.append(MarkdownBlock(id: blockId, type: .image(url: String(firstImage.output.url))))
                        blockId += 1
                    }
                    idx = firstImage.range.upperBound
                } else {
                    // if no image found, add the rest of the text to blocks, if it exists
                    let remainder = text[idx...]
                    if !remainder.isEmpty { blocks.append(MarkdownBlock(id: blockId, type: .text(String(remainder)))) }
                    blockId += 1
                    idx = text.endIndex // softly end loop
                }
            } catch {
                print("regex error occurred!")
            }
        }
        
        return blocks
    }

    func renderAsMarkdown(text: String, theme: Theme = .mlem) -> some View {
        Markdown(text)
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .top : .topLeading)
            .multilineTextAlignment(alignment)
            .markdownTheme(theme)
    }
}

// swiftlint:enable file_length
