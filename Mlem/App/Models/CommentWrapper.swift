//
//  CommentWrapper.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class CommentWrapper: Identifiable {
    let comment: Comment2
    private(set) var children: [CommentWrapper]
    weak var parent: CommentWrapper?
    
    var id: Int { comment.id }
    
    init(_ comment: Comment2) {
        self.comment = comment
        self.children = []
    }
    
    func addChild(_ child: CommentWrapper) {
        child.parent = self
        children.append(child)
    }
    
    func tree() -> [CommentWrapper] {
        children.reduce([self]) { $0 + $1.tree() }
    }
}
