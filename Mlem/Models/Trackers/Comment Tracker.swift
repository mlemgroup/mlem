//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class CommentTracker: ObservableObject {
    @Published var comments: [HierarchicalComment] = .init()
    @Published var isLoading: Bool = true
    
    private var ids: Set<Int> = .init()
    
    private(set) var treeView: [HierarchicalComment] = []
    private(set) var flatView: [HierarchicalComment] = []
    func setComments(_ treeView: [HierarchicalComment]) {
        self.treeView = treeView
        self.flatView = treeView.flatMap(flatMapChildren)
        self.comments = flatView
    }
    func flatMapChildren(_ comment: HierarchicalComment) -> [HierarchicalComment] {
        return [comment] + comment.children.flatMap(flatMapChildren)
    }
    
    func setCollapsed(_ isCollapsed: Bool, comment: HierarchicalComment) {
//      _setCollapsedUsingTreeView(isCollapsed, rootComment: comment)
        _setCollapsedUsingFlatView(isCollapsed, comment: comment)
    }
    
    private func _setCollapsedUsingTreeView(_ isCollapsed: Bool, rootComment: HierarchicalComment) {
        let rootPath = rootComment.commentView.comment.path
        guard let rootPathAsParent = rootPath.components(separatedBy: ".").last else {
            return
        }
        guard !rootComment.children.isEmpty else {
            rootComment.isCollapsed = isCollapsed
            return
        }
        /// - Always toggle collapsed state on requested `rootComment`.
        /// - Update child comment's `isParentCollapsed`.
        /// - If child comment `self.isCollapsed == true`, set (or keep) all of its child comments to `isParentCollapsed = true`
        
        let isRootCollapsed = !rootComment.isCollapsed
        treeView.forEach { comment in
            let thisPath = comment.commentView.comment.path
            let isChild = thisPath
                .components(separatedBy: ".")
                .contains { $0 == rootPathAsParent }
            guard isChild else {
                return
            }
            
//            if thisPath == rootPath {
//                /// - Always toggle collapsed state on requested `rootComment`.
//                comment.isCollapsed.toggle()
//            } else {
//                /// - Update child comment's `isParentCollapsed`.
//                comment.isParentCollapsed = isRootCollapsed
//            }
            
            if comment.isCollapsed {
//                _setCollapsedUsingTreeView(true, rootComment: <#T##HierarchicalComment#>)
            }
        }
    }
    private func _setCollapsedUsingFlatView(_ isCollapsed: Bool, comment: HierarchicalComment) {
        let parentPath = comment.commentView.comment.path
        guard let commentPathAsParent = parentPath.components(separatedBy: ".").last else {
            return
        }
        let collapseChildren = !comment.isCollapsed
        var collapsedParents: [String] = comment.isCollapsed ? [commentPathAsParent] : []
        flatView.forEach {
            let thisPath = $0.commentView.comment.path
            let thisParentPath = thisPath.components(separatedBy: ".").last!
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
            } else {
                /// Child comment.
                print("child comment \($0.commentView.comment.path) collapse: \(!comment.isCollapsed)")
                $0.isParentCollapsed = collapseChildren // collapsedParents.contains(thisParentPath)
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
