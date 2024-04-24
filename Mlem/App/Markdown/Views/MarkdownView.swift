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
            ForEach(blocks, id: \.self) { block in
                switch block {
                case let .paragraph(content: content):
                    MarkdownTextView(content)
                default:
                    Text("???")
                }
            }
        }
    }
}
