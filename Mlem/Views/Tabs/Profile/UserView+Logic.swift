//
//  UserView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import Foundation

extension UserView {
    func tryReloadUser() async {
        do {
            let authoredContent = try await personRepository.loadUserDetails(for: user.userId, limit: internetSpeed.pageSize)
            self.user = UserModel(from: authoredContent.personView)
            
            var savedContentData: GetPersonDetailsResponse?
            if isOwnProfile {
                savedContentData = try await personRepository.loadUserDetails(
                    for: user.userId,
                    limit: internetSpeed.pageSize,
                    savedOnly: true
                )
            }
            
            // accumulate comments and posts so we don't update state more than we need to
            var newComments = authoredContent.comments
                .sorted(by: { $0.comment.published > $1.comment.published })
                .map { HierarchicalComment(comment: $0, children: [], parentCollapsed: false, collapsed: false) }
            
            var newPosts = authoredContent.posts.map { PostModel(from: $0) }
            
            // add saved content, if present
            if let savedContent = savedContentData {
                newComments.append(contentsOf:
                    savedContent.comments
                        .sorted(by: { $0.comment.published > $1.comment.published })
                        .map { HierarchicalComment(comment: $0, children: [], parentCollapsed: false, collapsed: false) })
                
                newPosts.append(contentsOf: savedContent.posts.map { PostModel(from: $0) })
            }
            
            privateCommentTracker.comments = newComments
            privatePostTracker.reset(with: newPosts)
            
            self.isLoadingContent = false
//
//            errorDetails = nil
        } catch {
//                errorDetails = ErrorDetails(error: error, refresh: {
//                    await tryReloadUser()
//                    return userDetails != nil
//                })
                errorHandler.handle(
                    .init(
                        title: "Couldn't load user info",
                        message: "There was an error while loading user information.\nTry again later.",
                        underlyingError: error
                    )
                )
            }
    }
}
