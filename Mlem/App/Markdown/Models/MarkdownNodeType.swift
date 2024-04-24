//
//  MarkdownNodeType.swift
//  Mlem
//
//  Created by Sjmarf on 22/04/2024.
//

import Foundation

enum MarkdownNodeType: String {
    case document
    case blockquote = "block_quote"
    case list
    case item
    case codeBlock = "code_block"
    case customBlock = "custom_block"
    case paragraph
    case heading
    case thematicBreak = "thematic_break"
    case text
    case softBreak = "softbreak"
    case lineBreak = "linebreak"
    case code
    case customInline = "custom_inline"
    case emphasis = "emph"
    case strong
    case link
    case image
    case spoiler
    case superscript = "super"
    case `subscript` = "sub"
    case inlineAttributes = "attribute"
    case none = "NONE"
    case unknown = "<unknown>"

    // Extensions

    case strikethrough = "strike"
    case table
    case tableHead = "table_header"
    case tableRow = "table_row"
    case tableCell = "table_cell"
    case taskListItem = "tasklist"
}
