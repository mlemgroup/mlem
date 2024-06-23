//
//  BanUserView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 09/03/2024.
//

import SwiftUI

extension BanUserView {
    func confirm() {
        if banFromInstance {
            guard user.canBeAdministrated() else {
                assertionFailure("BanUserView opened with non-administratable user!")
                return
            }
            instanceBan()
        } else {
            guard let community = communityContext else {
                assertionFailure("banFromInstance false but communityContext nil!")
                return
            }
            guard user.canBeModerated(in: community) else {
                assertionFailure("BanUserView opened with non-moderatable user!")
                return
            }
            communityBan(from: community)
        }
    }
    
    func instanceBan() {
        isWaiting = true
        Task {
            let reason = reason.isEmpty ? nil : reason
            var user = user
            await user.toggleBan(
                expires: expires,
                reason: reason,
                removeData: removeContent
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(user.banned)
        }
    }
    
    func communityBan(from community: CommunityModel) {
        isWaiting = true
        Task {
            let updatedBannedStatus = await community.banUser(
                userId: user.userId,
                ban: shouldBan,
                removeData: removeContent,
                reason: reason.isEmpty ? nil : reason,
                expires: expires
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(updatedBannedStatus)
        }
    }
    
    func handleResult(_ result: Bool) async {
        if result == shouldBan {
            await notifier.add(.success("\(verb.capitalized)ned User"))
            
            if let callback {
                callback()
            }
            
            await MainActor.run {
                userRemovalWalker.modify(
                    userId: user.userId,
                    postAction: { post in
                        if banFromInstance {
                            post.creator.banned = shouldBan
                        } else {
                            post.creatorBannedFromCommunity = shouldBan
                        }
                    },
                    commentAction: { comment in
                        if banFromInstance {
                            comment.commentView.creator.banned = shouldBan
                        } else {
                            comment.commentView.creatorBannedFromCommunity = shouldBan
                        }
                    },
                    inboxAction: { item in
                        if banFromInstance {
                            item.setCreatorBannedFromInstance(shouldBan)
                        } else {
                            item.setCreatorBannedFromCommunity(shouldBan)
                        }
                    },
                    voteAction: { vote in
                        if banFromInstance {
                            vote.user.banned = shouldBan
                        } else {
                            vote.creatorBannedFromCommunity = shouldBan
                        }
                    }
                )
            }
            
            DispatchQueue.main.async {
                dismiss()
            }
        } else {
            await notifier.add(.failure("Failed to \(verb) user"))
        }
    }
}
