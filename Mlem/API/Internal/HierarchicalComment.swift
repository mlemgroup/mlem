//
//  HierarchicalComment.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

/// A model which represents a comment and it's child relationships
class HierarchicalComment: ObservableObject {
    let commentView: APICommentView
    var children: [HierarchicalComment]
    /// Indicates comment's position in a post's parent/child comment thread.
    ///
    /// Values range from `0...Int.max`, where 0 indicates the parent comment.
    let depth: Int
    
    /// The *closest* parent's collapsed state.
    @Published var isParentCollapsed: Bool = false
    /// Indicates whether the *current* comment is collapsed.
    @Published var isCollapsed: Bool = false

    init(comment: APICommentView, children: [HierarchicalComment], parentCollapsed: Bool, collapsed: Bool) {
        self.commentView = comment
        self.children = children
        self.depth = max(0, commentView.comment.path.split(separator: ".").count - 2)
        self.isParentCollapsed = parentCollapsed
        self.isCollapsed = collapsed
    }
}

extension HierarchicalComment: Identifiable {
    var id: Int { commentView.id }
}

extension [HierarchicalComment] {

    /// A method to insert an updated `APICommentView` into this array of `HierarchicalComment`
    /// - Parameter commentView: The `APICommentView` you wish to insert
    /// - Returns: An optional `HierarchicalComment` containing the updated comment and it's original chidren if found
    @discardableResult mutating func update(with commentView: APICommentView) -> HierarchicalComment? {
        return self.insert(commentView: commentView)
    }

    private mutating func insert(commentView: APICommentView) -> HierarchicalComment? {
        let targetId = commentView.id

        for (index, element) in self.enumerated() {
            if element.id == targetId {
                // we've found the comment we're targeting so re-create it and ensure we retain it's children
                let updatedComment = HierarchicalComment(
                    comment: commentView,
                    children: element.children,
                    parentCollapsed: element.isParentCollapsed,
                    collapsed: element.isCollapsed)
                self[index] = .init(
                    comment: commentView,
                    children: element.children,
                    parentCollapsed: element.isParentCollapsed,
                    collapsed: element.isCollapsed)
                return updatedComment
            } else if let updatedComment = self[index].children.insert(commentView: commentView) {
                // if the parent wasn't the target, recursively check the children before moving on...
                return updatedComment
            }
        }

        return insertReply(commentView: commentView)
    }

    private mutating func insertReply(commentView: APICommentView) -> HierarchicalComment? {
        guard let parentId = commentView.comment.parentId else {
            // can't be a reply without a parent 🤷
            return nil
        }

        for (index, element) in self.enumerated() {
            if element.id == parentId {
                // we've found the comment we're replying too, so re-create it and append this to it's children
                let reply = HierarchicalComment(
                    comment: commentView,
                    children: [],
                    parentCollapsed: element.isParentCollapsed,
                    collapsed: element.isCollapsed)
                let updatedParent = self[index]
                updatedParent.children.append(reply)
                self[index] = updatedParent
                return reply
            } else if let reply = self[index].children.insertReply(commentView: commentView) {
                // recursively check the children before moving on...
                return reply
            }
        }

        return nil
    }
}

internal extension HierarchicalComment {
    
    /// Recursively flat maps `comment.children`, preprending `comment` to that array.
    ///
    /// For example: Pass this function into `flatMap()` on array of parent `HierarchicalComment`s in order to construct an array of parent/child `[HierarchicalComment]` in a single array.
    static func recursiveFlatMap(_ comment: HierarchicalComment) -> [HierarchicalComment] {
        [comment] + comment.children.flatMap(recursiveFlatMap)
    }
}

// MARK: - Expanded/Collapsed State
internal extension HierarchicalComment {
    
    /// Sets this comment's collapsed state, while updating children with closest (and applicable) parent's collapsed state.
    func setCollapsed(_ isCollapsed: Bool) {
        self.isCollapsed = isCollapsed
        self.children.forEach { child in
            self.setParentCollapsed(isCollapsed)
        }
    }
    
    /// Recursively sets comment's `isParentCollapsed` state using the closest (and applicable) parent's value.
    private func setParentCollapsed(_ isParentCollapsed: Bool) {
        self.isParentCollapsed = isParentCollapsed
        self.children.forEach { child in
            /// If self is collapsed, all children's isParentCollapsed must also be true, since it's the closest parent that matters.
            let closestParentCollapsed = self.isCollapsed ? true : isParentCollapsed
            child.setParentCollapsed(closestParentCollapsed)
        }
    }
}

extension [APICommentView] {

    /// A representation of this array of `APICommentView` in a hierarchy that is suitable for rendering the UI with parent/child relationships
    var hierarchicalRepresentation: [HierarchicalComment] {
        var allComments = self
        
        let childrenStartIndex = allComments.partition(by: { $0.comment.parentId != nil })
        let children = allComments[childrenStartIndex...]
        
        var childrenById = [APICommentView.ID: [APICommentView.ID]]()
        children.forEach { child in
            guard let parentId = child.comment.parentId else { return }
            childrenById[parentId] = (childrenById[parentId] ?? []) + [child.id]
        }
        
        let identifiedComments = Dictionary(uniqueKeysWithValues: allComments.lazy.map { ($0.id, $0) })
        
        /// Recursively populates child comments by looking up IDs from `childrenById`
        func populateChildren(_ comment: APICommentView) -> HierarchicalComment {
            guard let childIds = childrenById[comment.id] else {
                return .init(
                    comment: comment,
                    children: [],
                    parentCollapsed: false,
                    collapsed: false)
            }
            
            let commentWithChildren = HierarchicalComment(
                comment: comment,
                children: [],
                parentCollapsed: false,
                collapsed: false)
            commentWithChildren.children = childIds
                .compactMap { id -> HierarchicalComment? in
                    guard let child = identifiedComments[id] else { return nil }
                    return populateChildren(child)
                }
            
            return commentWithChildren
        }
        
        let parents = allComments[..<childrenStartIndex]
        let result = parents.map(populateChildren)
        return result
    }
}
