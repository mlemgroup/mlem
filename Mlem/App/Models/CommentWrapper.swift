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
    
    var api: ApiClient { comment2.api }
    
    /// Returns the top-level parent
    var topParent: CommentWrapper { parent?.topParent ?? self }
}

extension [CommentWrapper] {
    func tree() -> [CommentWrapper] {
        reduce([]) { $0 + $1.tree() }
    }
}
