//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-07.
//

import Foundation

public extension Icon {
    struct MarkdownIcons {
        let bold: Icon = .baseOnly("bold")
        let italic: Icon = baseOnly("italic")
        let strikethrough: Icon = .baseOnly("strikethrough")
        let superscript: Icon = .baseOnly("textformat.superscript")
        let `subscript`: Icon = .baseOnly("textformat.subscript")
        // Potentially "chevron.left.chevron.right" is better, it's iOS 18+ though
        let inlineCode: Icon = .baseOnly("chevron.left.forwardslash.chevron.right")
        let quote: Icon = .baseOnly("quote.opening")
        let heading: Icon = .baseOnly("textformat.size")
        let uploadImage: Icon = .baseOnly("photo")
        let spoiler: Icon = baseOnly("eye")
        let codeBlock: Icon = baseOnly("text.viewfinder")
    }
    
    static let markdown: MarkdownIcons = .init()
}
