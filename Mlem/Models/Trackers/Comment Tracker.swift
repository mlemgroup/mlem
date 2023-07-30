//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class CommentTracker: ObservableObject {
    @Published var commentsView: [HierarchicalComment] = .init()
    @Published var isLoading: Bool = true
    
    private var ids: Set<Int> = .init()

    private var _comments: [HierarchicalComment] = []
    var comments: [HierarchicalComment] {
        get { _comments }
        set {
            _comments = newValue
            self.commentsView = _comments.flatMap(flatMapChildren)
        }
    }
    
    private func flatMapChildren(_ comment: HierarchicalComment) -> [HierarchicalComment] {
        return [comment] + comment.children.flatMap(flatMapChildren)
    }
    
    func setCollapsed(_ isCollapsed: Bool, comment: HierarchicalComment) {
        _setCollapsedUsingFlatView(isCollapsed, comment: comment)
    }
    
    private func _setCollapsedUsingFlatView(_ isCollapsed: Bool, comment: HierarchicalComment) {
        let parentPath = comment.commentView.comment.path
        guard let commentPathAsParent = parentPath.components(separatedBy: ".").last else {
            return
        }
        let collapseChildren = !comment.isCollapsed
        commentsView.forEach {
            let thisPath = $0.commentView.comment.path
            let isChild = thisPath
                .components(separatedBy: ".")
                .contains { $0 == commentPathAsParent }
            guard isChild else {
                print("skip comment \($0.commentView.comment.path), not child")
                return
            }
            if thisPath == parentPath {
                /// This is the parent comment: Keep partially visible.
                /// This should only run once.
                print("parent comment \(parentPath) collapse: \(!$0.isCollapsed)")
                $0.isCollapsed.toggle()
                /// isCollapsed == isParentCollapsed, when comment is a parent comment.
                if $0.commentView.comment.parentId == nil {
                    $0.isParentCollapsed.toggle()
                }
            } else {
                /// Child comment.
                print("child comment \($0.commentView.comment.path) collapse: \(!comment.isCollapsed)")
                $0.isParentCollapsed = collapseChildren
            }
        }
    }
    
    /// A method to add new comments into the tracker, duplicate comments will be rejected
    func add(_ newComments: [HierarchicalComment]) {
        let accepted = newComments.filter { ids.insert($0.id).inserted }
        comments.append(contentsOf: accepted)
    }
    
    // Takes a callback and fillters out any entry that returns false
    //
    // Returns the number of entries removed
    @discardableResult func filter(_ callback: (HierarchicalComment) -> Bool) -> Int {
        var removedElements = 0
        
        comments = comments.filter({
            let filterResult = callback($0)
            
            // Remove the ID from the IDs set as well
            if !filterResult {
                ids.remove($0.id)
                removedElements += 1
            }
            return filterResult
        })
        
        return removedElements
    }
}
