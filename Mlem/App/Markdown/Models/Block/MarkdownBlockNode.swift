//
//  MarkdownBlockNode.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation

enum MarkdownBlockNode: Hashable, MarkdownContainer {
    case blockquote(blocks: [MarkdownBlockNode])
    case spoiler(title: String?, blocks: [MarkdownBlockNode])
    case bulletedList(isTight: Bool, items: [MarkdownRawListItem])
    case numberedList(isTight: Bool, start: Int, items: [MarkdownRawListItem])
    case codeBlock(fenceInfo: String?, content: String)
    case paragraph(inlines: [MarkdownInlineNode])
    case heading(level: Int, inlines: [MarkdownInlineNode])
    // case table(columnAlignments: [RawTableColumnAlignment], rows: [RawTableRow])
    case thematicBreak
    
    var children: [any MarkdownContainer] {
        switch self {
        case let .blockquote(blocks):
            return blocks
        case let .paragraph(inlines):
            return inlines
        case let .heading(_, inlines):
            return inlines
        case let .spoiler(_, blocks: blocks):
            return blocks
        case let .bulletedList(_, items: items):
            return items
        case let .numberedList(_, _, items: items):
            return items
        default:
            return []
        }
    }
    
    var searchChildrenForLinks: Bool {
        switch self {
        case .spoiler:
            false
        default:
            true
        }
    }
}

struct MarkdownRawListItem: Hashable, MarkdownContainer {
    var searchChildrenForLinks: Bool { true }
    
    let blocks: [MarkdownBlockNode]
    
    var children: [MarkdownContainer] { blocks }
}

extension MarkdownRawListItem {
    init(unsafeNode: UnsafeMarkdownNode) {
        guard unsafeNode.nodeType == .item else {
            fatalError("Expected a list item but got a '\(unsafeNode.nodeType)' instead.")
        }
        self.init(blocks: unsafeNode.children.compactMap(MarkdownBlockNode.init(unsafeNode:)))
    }
}

extension MarkdownBlockNode {
    // swiftlint:disable:next cyclomatic_complexity
    init?(unsafeNode: UnsafeMarkdownNode) {
        switch unsafeNode.nodeType {
        case .blockquote:
            self = .blockquote(blocks: unsafeNode.children.compactMap(MarkdownBlockNode.init(unsafeNode:)))
        case .list:
            switch unsafeNode.listType {
            case CMARK_BULLET_LIST:
                self = .bulletedList(
                    isTight: unsafeNode.isTightList,
                    items: unsafeNode.children.map(MarkdownRawListItem.init(unsafeNode:))
                )
            case CMARK_ORDERED_LIST:
                self = .numberedList(
                    isTight: unsafeNode.isTightList,
                    start: unsafeNode.listStart,
                    items: unsafeNode.children.map(MarkdownRawListItem.init(unsafeNode:))
                )
            default:
                assertionFailure("cmark reported a list node without a list type.")
                self = .paragraph(inlines: [.text("???")])
            }
        case .codeBlock:
            self = .codeBlock(fenceInfo: unsafeNode.fenceInfo, content: unsafeNode.literal ?? "")
        case .paragraph:
            self = .paragraph(inlines: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .heading:
            self = .heading(
                level: unsafeNode.headingLevel,
                inlines: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:))
            )
        //    case .table:
        //      self = .table(
        //        columnAlignments: unsafeNode.tableAlignments,
        //        rows: unsafeNode.children.map(RawTableRow.init(unsafeNode:))
        //      )
        case .spoiler:
            self = .spoiler(
                title: unsafeNode.title,
                blocks: unsafeNode.children.compactMap(MarkdownBlockNode.init(unsafeNode:))
            )
        case .thematicBreak:
            self = .thematicBreak
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in BlockNode.")
            return nil
        }
    }
}
