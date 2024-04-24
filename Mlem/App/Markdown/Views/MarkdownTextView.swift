//
//  MarkdownText.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import SwiftUI

struct MarkdownTextView: View {
    var inlines: [MarkdownInlineNode]
    
    init(_ inlines: [MarkdownInlineNode]) {
        self.inlines = inlines
    }
    
    init(_ string: String) {
        let blocks = UnsafeMarkdownNode.parseMarkdown(markdown: string) ?? []
        self.init(blocks.first?.children as? [MarkdownInlineNode] ?? [])
    }
    
    var attributedString: AttributedString {
        inlines.reduce(AttributedString()) { $1.attributedString(attributedString: $0) }
    }
    
    var body: some View {
        Text(attributedString)
    }
}
