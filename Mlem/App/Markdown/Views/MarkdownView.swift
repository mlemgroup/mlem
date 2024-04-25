//
//  Markdown.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import SwiftUI

struct MarkdownView: View {
    var blocks: [MarkdownBlockNode]
    
    init(_ string: String) {
        self.init(UnsafeMarkdownNode.parseMarkdown(markdown: string) ?? [])
    }
    
    init(_ blocks: [MarkdownBlockNode]) {
        self.blocks = blocks
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                Group {
                    switch block {
                    case let .paragraph(inlines: inlines):
                        MarkdownTextView(inlines)
                    case let .heading(level: level, inlines: inlines):
                        heading(level: level, inlines: inlines)
                    case let .blockquote(blocks: blocks):
                        blockQuote(blocks: blocks)
                    case let .spoiler(title: title, inlines: inlines):
                        MarkdownSpoilerView(title: title, inlines: inlines)
                    case let .codeBlock(fenceInfo: _, content: content):
                        codeBlock(content: content)
                    case .thematicBreak:
                        Rectangle()
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                    case let .bulletedList(isTight: _, items: items):
                        bulletedList(items: items)
                    case let .numberedList(isTight: _, start: start, items: items):
                        numberedList(items: items, startIndex: start)
                    default:
                        Text("???")
                    }
                }
                .padding(.top, (index == 0) ? 0 : blockPadding(block, edge: .top))
                .padding(.bottom, (index == blocks.count - 1) ? 0 : blockPadding(block, edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func blockPadding(_ block: MarkdownBlockNode, edge: VerticalEdge) -> CGFloat {
        8
    }
    
    @ViewBuilder
    func heading(level: Int, inlines: [MarkdownInlineNode]) -> some View {
        Group {
            switch level {
            case 1:
                VStack(alignment: .leading, spacing: 0) {
                    MarkdownTextView(inlines)
                        .font(.title)
                        .fontWeight(.bold)
                    Divider()
                }
            case 2:
                MarkdownTextView(inlines)
                    .font(.title2)
                    .fontWeight(.bold)
            case 3:
                MarkdownTextView(inlines)
                    .font(.title3)
                    .fontWeight(.semibold)
            default:
                MarkdownTextView(inlines)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    func blockQuote(blocks: [MarkdownBlockNode]) -> some View {
        MarkdownView(blocks)
            .padding(.leading, 15)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)
            }
    }
    
    @ViewBuilder
    func codeBlock(content: String) -> some View {
        Text(content.trimmingCharacters(in: .newlines))
            .monospaced()
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
    }
    
    @ViewBuilder
    func bulletedList(items: [MarkdownRawListItem]) -> some View {
        VStack(spacing: 3) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(Color(uiColor: .tertiaryLabel))
                        .frame(width: 6, height: 6)
                    MarkdownView(item.children)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func numberedList(items: [MarkdownRawListItem], startIndex: Int = 1) -> some View {
        VStack(spacing: 3) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .center, spacing: 7) {
                    Text("\(startIndex + index).")
                        .foregroundStyle(.secondary)
                    MarkdownView(item.children)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
