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
            instanceBan()
        } else if let communityContext {
            communityBan(from: communityContext)
        } else {
            assertionFailure("banFromInstance false but communityContext nil!")
        }
    }
    
    func instanceBan() {
        isWaiting = true
        Task {
            let reason = reason.isEmpty ? nil : reason
            var user = user
            
            if contentRemovalType == .purge && isPermanent {
                let response = await user.purge(reason: reason)
                DispatchQueue.main.async {
                    isWaiting = false
                }
                await handleResult(response)
            } else {
                await user.toggleBan(
                    expires: expires,
                    reason: reason,
                    removeData: contentRemovalType == .remove
                )
                DispatchQueue.main.async {
                    isWaiting = false
                }
                
                await handleResult(user.banned)
            }
        }
    }
    
    func communityBan(from community: CommunityModel) {
        isWaiting = true
        Task {
            let updatedBannedStatus = await community.banUser(
                userId: user.userId,
                ban: shouldBan,
                removeData: contentRemovalType == .remove,
                reason: reason.isEmpty ? nil : reason,
                expires: expires
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(updatedBannedStatus)
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func handleResult(_ result: Bool) async {
        if result == shouldBan {
            await notifier.add(.success("\(verb.capitalized)ned User"))
            
            await MainActor.run {
                if let postTracker {
                    for post in postTracker.items where post.creator.userId == user.userId {
                        if contentRemovalType == .purge {
                            post.purged = true
                        } else if banFromInstance {
                            post.creator.banned = shouldBan
                        } else {
                            post.creatorBannedFromCommunity = shouldBan
                        }
                    }
                }
                if let commentTracker {
                    for comment in commentTracker.comments where comment.commentView.comment.creatorId == user.userId {
                        if contentRemovalType == .purge {
                            comment.purged = true
                        } else if banFromInstance {
                            comment.commentView.creator.banned = shouldBan
                        } else {
                            comment.commentView.creatorBannedFromCommunity = shouldBan
                        }
                    }
                }
                
                if let votesTracker {
                    if let index = votesTracker.votes.firstIndex(where: {$0.id == user.userId}) {
                        if contentRemovalType == .purge {
                            votesTracker.votes.remove(at: index)
                        } else if banFromInstance {
                            votesTracker.votes[index].user.banned = shouldBan
                        } else {
                            votesTracker.votes[index].creatorBannedFromCommunity = shouldBan
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                dismiss()
            }
        } else {
            await notifier.add(.failure("Failed to \(verb) user"))
        }
    }
}
