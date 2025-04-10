//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-07.
//

import Foundation

public extension Icon {
    struct MarkdownIcons {
        public let bold: Icon = .init("bold")
        public let italic: Icon = .init("italic")
        public let strikethrough: Icon = .init("strikethrough")
        public let superscript: Icon = .init("textformat.superscript")
        public let `subscript`: Icon = .init("textformat.subscript")
        // Potentially "chevron.left.chevron.right" is better, it's iOS 18+ though
        public let inlineCode: Icon = .init("chevron.left.forwardslash.chevron.right")
        public let quote: Icon = .init("quote.opening")
        public let heading: Icon = .init("textformat.size")
        public let spoiler: Icon = .init("eye")
        public let codeBlock: Icon = .init("text.viewfinder")
        
        @inlinable public var insertLink: Icon { .general.link }
        @inlinable public var uploadImage: Icon { .general.chooseImage }
    }
    
    static let markdown: MarkdownIcons = .init()
}
