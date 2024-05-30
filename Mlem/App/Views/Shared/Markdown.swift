//
//  Markdown.swift
//  Mlem
//
//  Created by Sjmarf on 25/04/2024.
//

import Dependencies
import LemmyMarkdownUI
import Nuke
import SwiftUI

struct Markdown: View {
    @Environment(Palette.self) var palette
    
    let blocks: [BlockNode]
    
    init(_ markdown: String) {
        self.blocks = .init(markdown)
    }
    
    init(_ blocks: [BlockNode]) {
        self.blocks = blocks
    }
    
    var body: some View {
        LemmyMarkdownUI.Markdown(
            blocks,
            configuration: .default
        )
    }
}
