//
//  Markdown View.swift
//  Mlem
//
//  Created by David Bureš on 18.05.2023.
//

import Foundation
import MarkdownUI
import SwiftUI
import RegexBuilder

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
            Image(systemName: configuration.isCompleted ? "checkmark.square.fill" : "square")
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

/**
 Little helper struct to help with the fact that we need to handle images specially
 */
struct MarkdownBlock: Identifiable {
    let text: Substring
    let isImage: Bool
    let id: Int
}

struct MarkdownView: View {

    @State var text: String
    let isNsfw: Bool
    let replaceImagesWithEmoji: Bool
    
    init(text: String, isNsfw: Bool, replaceImagesWithEmoji: Bool = false) {
        self.text = text
        self.isNsfw = isNsfw
        self.replaceImagesWithEmoji = replaceImagesWithEmoji
    }

    var body: some View {
        generateView()
    }

    @MainActor func generateView() -> some View {
        let blocks = parseMarkdownForImages(text: text)
        
        return VStack {
            ForEach(blocks) { block in
                if block.isImage {
                    if replaceImagesWithEmoji {
                        getMarkdown(text: AppConstants.pictureEmoji.randomElement() ?? "🖼️")
                    } else {
                        CachedImageWithNsfwFilter(isNsfw: isNsfw, url: URL(string: String(block.text)))
                    }
                } else {
                    getMarkdown(text: String(block.text))
                }
            }
        }
    }
    
    func parseMarkdownForImages(text: String) -> [MarkdownBlock] {
        // this will capture the "![label](url)" pattern so we can hanble it separately
        let imageLooker = Regex {
            "!["
            Capture {
                ZeroOrMore(.any, .reluctant) // captures the label of the image
            }
            "]("
            Capture {
                ZeroOrMore(.any, .reluctant) // captures the url of the image
            }
            ")"
        }
            .ignoresCase()
        
        var blocks: [MarkdownBlock] = .init()
        var idx: String.Index = .init(utf16Offset: 0, in: text)
        var blockId: Int = 0
        while idx < text.endIndex {
            do {
                if let firstImage = try imageLooker.firstMatch(in: text[idx...]) {
                    // if there is some image found, add it to blocks
                    if firstImage.range.lowerBound == idx {
                        // if the regex starts *right here*, add to images
                        blocks.append(MarkdownBlock(text: firstImage.output.2, isImage: true, id: blockId))
                        blockId += 1
                    } else {
                        // otherwise, add text in between, then first match
                        blocks.append(MarkdownBlock(text: text[idx..<firstImage.range.lowerBound], isImage: false, id: blockId))
                        blockId += 1
                        blocks.append(MarkdownBlock(text: firstImage.output.2, isImage: true, id: blockId))
                        blockId += 1
                    }
                    idx = firstImage.range.upperBound
                } else {
                    // if no image found, add the rest of the text to blocks, if it exists
                    let remainder = text[idx...]
                    if !remainder.isEmpty { blocks.append(MarkdownBlock(text: remainder, isImage: false, id: blockId)) }
                    blockId += 1
                    idx = text.endIndex // softly end loop
                }
            } catch {
                print("regex error occurred!")
            }
        }
        
        return blocks
    }

    func getMarkdown(text: String) -> some View {
        Markdown(text)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .markdownTheme(.mlem)
    }
}
