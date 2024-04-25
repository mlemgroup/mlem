//
//  MarkdownInlineNode.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation

enum MarkdownInlineNode: Hashable, MarkdownContainer {
    case text(String)
    case softBreak
    case lineBreak
    case code(String)
    case emphasis(children: [MarkdownInlineNode])
    case strong(children: [MarkdownInlineNode])
    case superscript(children: [MarkdownInlineNode])
    case `subscript`(children: [MarkdownInlineNode])
    case strikethrough(children: [MarkdownInlineNode])
    case link(destination: String, children: [MarkdownInlineNode])
    case image(source: String, children: [MarkdownInlineNode])
    
    var children: [any MarkdownContainer] { inlineChildren }
    
    var inlineChildren: [MarkdownInlineNode] {
        switch self {
        case let .emphasis(children):
            return children
        case let .strong(children):
            return children
        case let .superscript(children):
            return children
        case let .subscript(children):
            return children
        case let .strikethrough(children):
            return children
        case let .link(_, children):
            return children
        case let .image(_, children):
            return children
        default:
            return []
        }
    }
    
    var string: String? {
        switch self {
        case let .text(string):
            return string
        case let .code(string):
            return string
        case .softBreak:
            return " "
        case .lineBreak:
            return "\n"
        default:
            return nil
        }
    }
    
    var searchChildrenForLinks: Bool { true }
}

extension MarkdownInlineNode {
    // swiftlint:disable:next cyclomatic_complexity
    init?(unsafeNode: UnsafeMarkdownNode) {
        switch unsafeNode.nodeType {
        case .text:
            self = .text(unsafeNode.literal ?? "")
        case .softBreak:
            self = .softBreak
        case .lineBreak:
            self = .lineBreak
        case .code:
            self = .code(unsafeNode.literal ?? "")
        case .emphasis:
            self = .emphasis(children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .strong:
            self = .strong(children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .superscript:
            self = .superscript(children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .subscript:
            self = .subscript(children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .strikethrough:
            self = .strikethrough(children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .link:
            self = .link(
                destination: unsafeNode.url ?? "",
                children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:))
            )
        case .image:
            self = .image(
                source: unsafeNode.url ?? "",
                children: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:))
            )
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in InlineNode.")
            return nil
        }
    }
}
