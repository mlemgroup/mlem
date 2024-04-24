//
//  MarkdownBlockNode.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation

enum MarkdownBlockNode: Hashable, MarkdownContainer {
    case blockquote(children: [MarkdownBlockNode])
    //  case bulletedList(isTight: Bool, items: [RawListItem])
    //  case numberedList(isTight: Bool, start: Int, items: [RawListItem])
    //  case taskList(isTight: Bool, items: [RawTaskListItem])
    case codeBlock(fenceInfo: String?, content: String)
    case paragraph(content: [MarkdownInlineNode])
    case heading(level: Int, content: [MarkdownInlineNode])
    // case table(columnAlignments: [RawTableColumnAlignment], rows: [RawTableRow])
    case thematicBreak
    
    var children: [any MarkdownContainer] {
        switch self {
        case let .blockquote(children):
            return children
        case let .paragraph(content):
            return content
        case let .heading(_, content):
            return content
        default:
            return []
        }
    }
}

extension MarkdownBlockNode {
    init?(unsafeNode: UnsafeMarkdownNode) {
        switch unsafeNode.nodeType {
        case .blockquote:
            self = .blockquote(children: unsafeNode.children.compactMap(MarkdownBlockNode.init(unsafeNode:)))
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
            self = .paragraph(content: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:)))
        case .heading:
            self = .heading(
                level: unsafeNode.headingLevel,
                content: unsafeNode.children.compactMap(MarkdownInlineNode.init(unsafeNode:))
            )
        //    case .table:
        //      self = .table(
        //        columnAlignments: unsafeNode.tableAlignments,
        //        rows: unsafeNode.children.map(RawTableRow.init(unsafeNode:))
        //      )
        case .thematicBreak:
            self = .thematicBreak
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in BlockNode.")
            return nil
        }
    }
}
