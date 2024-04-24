//
//  [MarkdownBlockMode]+Links.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation

extension [MarkdownBlockNode] {
    var links: [(title: [MarkdownInlineNode], url: URL)] {
        var ret: [(title: [MarkdownInlineNode], url: URL)] = .init()
        var stack: [any MarkdownContainer] = self
        while let node = stack.popLast() {
            stack.append(contentsOf: node.children)
            if case let MarkdownInlineNode.link(destination: destination, children: children) = node {
                if let url = URL(string: destination) {
                    ret.append((title: children, url: url))
                }
            }
        }
        return ret
    }
}
