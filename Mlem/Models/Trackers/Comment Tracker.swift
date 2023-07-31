//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class CommentTracker: ObservableObject {
    @Published private(set) var commentsView: [HierarchicalComment] = .init()
    @Published var isLoading: Bool = true
    
    private var ids: Set<Int> = .init()

    private var _comments: [HierarchicalComment] = []
    var comments: [HierarchicalComment] {
        get { _comments }
        set {
            _comments = newValue
            self.commentsView = _comments.flatMap(HierarchicalComment.recursiveFlatMap)
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

// MARK: - Expand/Collapse Comments
extension CommentTracker {
    
    /// Mark `comment` as collapsed or not, triggering view updates, if necessary.
    func setCollapsed(_ isCollapsed: Bool, comment: HierarchicalComment) {
        _setCollapsed(isCollapsed, comment: comment, flatView: commentsView)
    }
    
    /// - Parameter flatView: A 1D array of `HierarchicalComment` of parent/child comments, where elements are ordered as they would appear on screen.
    private func _setCollapsed(_ isCollapsed: Bool, comment: HierarchicalComment, flatView: [HierarchicalComment]) {
        let parentPath = comment.commentView.comment.path
        guard let commentPathAsParent = parentPath.components(separatedBy: ".").last else {
            return
        }
        let collapseChildren = !comment.isCollapsed
        flatView.forEach {
            let thisPath = $0.commentView.comment.path
            let isChild = thisPath
                .components(separatedBy: ".")
                .contains { $0 == commentPathAsParent }
            guard isChild else {
                /// Skip this comment, not a child of parent at `parentPath`.
                return
            }
            if thisPath == parentPath {
                /// This is the parent comment: Keep partially visible.
                /// This should only run once.
                $0.isCollapsed.toggle()
                /// isCollapsed == isParentCollapsed, when comment is a parent comment.
                if $0.commentView.comment.parentId == nil {
                    $0.isParentCollapsed.toggle()
                }
            } else {
                // - TODO: We don't keep child comments collapsed if user toggles parent comment's collapsed state
                // 1. Collapse child comment.
                // 2. Collapse parent comment.
                // 3. Expand parent comment.
                // Expected: Original child comment to stay collapsed.
                // Actual: All child comments are toggled to expanded state.
                
                /// Child comment.
                /// Child may need to be collapsed even if comment itself isn't collapsed.
                $0.isParentCollapsed = collapseChildren
            }
        }
    }
}
