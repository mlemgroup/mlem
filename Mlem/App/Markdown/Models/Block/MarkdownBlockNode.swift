//
//  MarkdownBlockNode.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation

enum MarkdownBlockNode: Hashable, MarkdownContainer {
    case blockquote(blocks: [MarkdownBlockNode])
    case spoiler(title: String?, inlines: [MarkdownInlineNode])
    //  case bulletedList(isTight: Bool, items: [RawListItem])
    //  case numberedList(isTight: Bool, start: Int, items: [RawListItem])
    //  case taskList(isTight: Bool, items: [RawTaskListItem])
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
        default:
            return []
        }
    }
}

extension MarkdownBlockNode {
    init?(unsafeNode: UnsafeMarkdownNode) {
        switch unsafeNode.nodeType {
        case .blockquote:
            self = .blockquote(blocks: unsafeNode.children.compactMap(MarkdownBlockNode.init(unsafeNode:)))
        //    case .list:
        //      if unsafeNode.children.contains(where: \.isTaskListItem) {
        //        self = .taskList(
        //          isTight: unsafeNode.isTightList,
        //          items: unsafeNode.children.map(RawTaskListItem.init(unsafeNode:))
        //        )
        //      } else {
        //        switch unsafeNode.listType {
        //        case CMARK_BULLET_LIST:
        //          self = .bulletedList(
        //            isTight: unsafeNode.isTightList,
        //            items: unsafeNode.children.map(RawListItem.init(unsafeNode:))
        //          )
        //        case CMARK_ORDERED_LIST:
        //          self = .numberedList(
        //            isTight: unsafeNode.isTightList,
        //            start: unsafeNode.listStart,
        //            items: unsafeNode.children.map(RawListItem.init(unsafeNode:))
        //          )
        //        default:
        //          fatalError("cmark reported a list node without a list type.")
        //        }
        //      }
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
                inlines: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:))
            )
        case .thematicBreak:
            self = .thematicBreak
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in BlockNode.")
            return nil
        }
    }
}
