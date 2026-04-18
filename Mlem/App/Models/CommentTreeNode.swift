//
//  CommentWrapper.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class CommentTreeNode: Identifiable, Hashable {
    var comment: Comment
    private(set) var children: [CommentTreeNode] = []
    weak var parent: CommentTreeNode?
    var collapsed: Bool = false
    
    var id: Int { comment.id }
    
    init(_ comment: Comment) {
        self.comment = comment
    }
    
    func addChild(_ child: CommentTreeNode) {
        child.parent = self
        children.append(child)
    }
    
    func tree(hideIfCollapsed: Bool = true) -> [CommentTreeNode] {
        if comment.creator.value_?.blocked_.realizedValue ?? false { return [] }
        if collapsed, hideIfCollapsed { return [self] }
        return children.reduce([self]) { $0 + $1.tree() }
    }
    
    var recursiveChildCount: Int {
        children.reduce(0) { $0 + $1.recursiveChildCount + 1 }
    }
    
    var api: ApiClient { comment.api }
    var actorId: ActorIdentifier { comment.actorId }
    
    /// Returns the top-level parent
    var topParent: CommentTreeNode { parent?.topParent ?? self }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: CommentTreeNode, rhs: CommentTreeNode) -> Bool { lhs === rhs }
}

extension [CommentTreeNode] {
    func tree() -> [CommentTreeNode] {
        reduce([]) { $0 + $1.tree() }
    }
}
