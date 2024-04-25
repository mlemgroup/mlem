//
//  MarkdownSpoilerView.swift
//  Mlem
//
//  Created by Sjmarf on 24/04/2024.
//

import SwiftUI

struct MarkdownSpoilerView: View {
    @State var isCollapsed: Bool = true
    
    let titleInlines: [MarkdownInlineNode]
    let blocks: [MarkdownBlockNode]
    
    init(title: String?, blocks: [MarkdownBlockNode]) {
        if let title {
            self.titleInlines = UnsafeMarkdownNode.parseInlinesOnly(markdown: title) ?? [.text("Spoiler")]
        } else {
            self.titleInlines = [.text("Spoiler")]
        }
        self.blocks = blocks
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                MarkdownTextView(titleInlines)
            }
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isCollapsed.toggle()
                }
            }
            
            if !isCollapsed {
                MarkdownView(blocks)
                    .padding(10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .tertiaryLabel), lineWidth: 1)
        )
    }
}
