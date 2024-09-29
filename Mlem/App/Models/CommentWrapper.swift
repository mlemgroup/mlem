//
//  CommentWrapper.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class CommentWrapper: Identifiable, Comment2Providing {
    static var tierNumber: Int = 100
    
    var comment2: Comment2
    private(set) var children: [CommentWrapper] = []
    weak var parent: CommentWrapper?
    var collapsed: Bool = false
    
    var id: Int { comment2.id }
    
    init(_ comment: Comment2) {
        self.comment2 = comment
    }
    
    func addChild(_ child: CommentWrapper) {
        child.parent = self
        children.append(child)
    }
    
    func tree() -> [CommentWrapper] {
        if creator.blocked { return [] }
        if collapsed { return [self] }
        return children.reduce([self]) { $0 + $1.tree() }
    }
    
    func itemTree() -> [CommentTreeItem] {
        if creator.blocked { return [] }
        if collapsed { return [.comment(self)] }
        var output: [CommentTreeItem] = children.reduce([.comment(self)]) { $0 + $1.itemTree() }
        let directChildCount = children.reduce(commentCount) { $0 - $1.commentCount }
        if children.count < directChildCount {
            output.append(.unloadedComments(comment: self, count: commentCount - output.count))
        }
        return output
    }
    
    var recursiveChildCount: Int {
        children.reduce(0) { $0 + $1.recursiveChildCount + 1 }
    }
    
    var api: ApiClient { comment2.api }
    
    /// Returns the top-level parent
    var topParent: CommentWrapper { parent?.topParent ?? self }
}

extension [CommentWrapper] {
    func tree() -> [CommentWrapper] {
        reduce([]) { $0 + $1.tree() }
    }
    
    func itemTree() -> [CommentTreeItem] {
        reduce([]) { $0 + $1.itemTree() }
    }
}

enum CommentTreeItem: Hashable {
    case comment(CommentWrapper)
    case unloadedComments(comment: CommentWrapper, count: Int)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .comment(comment):
            hasher.combine(1)
            hasher.combine(comment.actorId)
        case let .unloadedComments(comment, _):
            hasher.combine(2)
            hasher.combine(comment.actorId)
        }
    }
}
