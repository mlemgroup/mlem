//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class CommentTracker: ObservableObject {
    @Published private(set) var commentsView: [HierarchicalComment] = .init()
    
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
        comment.setCollapsed(isCollapsed)
    }
    
    // swiftlint:disable line_length
    private func debugPrintComments(comment: HierarchicalComment) {
#if DEBUG
        func printComment(_ comment: HierarchicalComment) {
            print("\(comment.commentView.comment.path) \(comment.commentView.comment.content.prefix(30)) - parent: \(comment.isParentCollapsed), self: \(comment.isCollapsed)")
            comment.children.forEach(printComment)
        }
        print("* * *")
        printComment(comment)
#endif
    }
    // swiftlint:enable line_length
}
