//
//  UnsafeMarkdownNodeSequence.swift
//  Mlem
//
//  Created by Sjmarf on 22/04/2024.
//

import Foundation

struct UnsafeMarkdownNodeSequence: Sequence {
    struct Iterator: IteratorProtocol {
        private var node: UnsafeMarkdownNode?

        init(_ node: UnsafeMarkdownNode?) {
            self.node = node
        }

        mutating func next() -> UnsafeMarkdownNode? {
            guard let node else { return nil }
            defer { self.node = cmark_node_next(node) }
            return node
        }
    }

    private let node: UnsafeMarkdownNode?

    init(_ node: UnsafeMarkdownNode?) {
        self.node = node
    }

    func makeIterator() -> Iterator {
        .init(node)
    }
}
