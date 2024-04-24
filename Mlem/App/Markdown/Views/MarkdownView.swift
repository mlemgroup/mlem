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
            .foregroundStyle(.secondary)
            .padding(.leading, 15)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)
            }
    }
}
