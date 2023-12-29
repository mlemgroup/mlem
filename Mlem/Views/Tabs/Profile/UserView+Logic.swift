//
//  UserView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import SwiftUI

extension UserView {
    var isOwnProfile: Bool { user.userId == siteInformation.myUserInfo?.localUserView.person.id }
    
    var tabs: [UserViewTab] {
        var tabs: [UserViewTab] = [.overview, .posts, .comments]
        if isOwnProfile {
            tabs.append(.saved)
        }
        if !(user.moderatedCommunities?.isEmpty ?? true) {
            tabs.append(.communities)
        }
        return tabs
    }
    
    var cakeDayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMYY", options: 0, locale: Locale.current)
        return dateFormatter
    }
    
    var bioAlignment: TextAlignment {
        if let bio = user.bio {
            if bio.rangeOfCharacter(from: CharacterSet.newlines) != nil {
                return .leading
            }
            if bio.count > 100 {
                return .leading
            }
        }
        return .center
    }
    
    func tryReloadUser() async {
        do {
            let authoredContent = try await personRepository.loadUserDetails(for: user.userId, limit: internetSpeed.pageSize)
            self.user = UserModel(from: authoredContent)
            self.communityTracker.replaceAll(with: user.moderatedCommunities?.map { AnyContentModel($0) } ?? [])
            
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
