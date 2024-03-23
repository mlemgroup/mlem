//
//  UserView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import SwiftUI

extension UserView {
    var isOwnProfile: Bool { user.userId == siteInformation.myUserInfo?.localUserView.person.id }
    var canAppointAsMod: Bool {
        siteInformation.myUser?.isAdmin ?? false ||
            (!isOwnProfile && !siteInformation.moderatedCommunities.isEmpty)
    }
    
    var menuFunctions: [MenuFunction] {
        var ret = user.menuFunctions({ user = $0 }, modToolTracker: modToolTracker)
        
        // add moderator needs to be defined as a menu function out here instead of within the user model so that it can take the $user binding
        // TODO: 2.0 move add moderator menu function into Person
        if canAppointAsMod {
            ret.append(.standardMenuFunction(
                text: "Appoint as Moderator",
                imageName: Icons.moderation
            ) {
                modToolTracker.addModerator(user: $user, to: nil)
            })
        }
        return ret
    }
    
    var tabs: [UserViewTab] {
        var tabs: [UserViewTab] = [.overview, .posts, .comments]
        
        if !(user.moderatedCommunities?.isEmpty ?? true) {
            tabs.append(.communities)
        }
        
        return tabs
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
            let authoredContent: GetPersonDetailsResponse
            if user.usesExternalData {
                authoredContent = try await personRepository.loadUserDetails(for: user.profileUrl, limit: internetSpeed.pageSize)
            } else {
                authoredContent = try await personRepository.loadUserDetails(for: user.userId, limit: internetSpeed.pageSize)
            }
             
            var newUser = UserModel(from: authoredContent)
            newUser.isAdmin = user.isAdmin
            user = newUser
            
            communityTracker.replaceAll(with: user.moderatedCommunities ?? [])
            
            // accumulate comments and posts so we don't update state more than we need to
            var newComments = authoredContent.comments
                .sorted(by: { $0.comment.published > $1.comment.published })
                .map { HierarchicalComment(comment: $0, children: [], parentCollapsed: false, collapsed: false) }
            
            var newPosts = authoredContent.posts.map { PostModel(from: $0) }
            
            privateCommentTracker.comments = newComments
            await privatePostTracker.reset(with: newPosts)
            
            withAnimation(.easeOut(duration: 0.2)) {
                isLoadingContent = false
            }
            
        } catch {
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
