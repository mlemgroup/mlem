//
//  CommentItem+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 27/03/2024.
//

import Foundation
import SwiftUI

// swiftlint:disable function_body_length

extension CommentItem {
    func combinedMenuFunctions(community: CommunityModel?) -> [MenuFunction] {
        @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
        let isMod = siteInformation.isModOrAdmin(communityId: hierarchicalComment.commentView.post.communityId)
        
        var functions: [MenuFunction] = .init()
        
        functions.append(contentsOf: personalMenuFunctions())
        if isMod {
            if moderatorActionGrouping != .none {
                functions.append(
                    .groupMenuFunction(
                        text: "Moderation",
                        imageName: Icons.moderation,
                        children: modMenuFunctions(community: community)
                    )
                )
            } else {
                functions.append(contentsOf: modMenuFunctions(community: community))
            }
        }
        return functions
    }
    
    func personalMenuFunctions() -> [MenuFunction] {
        let isMod = siteInformation.isModOrAdmin(communityId: hierarchicalComment.commentView.post.communityId)
        
        var functions: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = hierarchicalComment.commentView.myVote == .upvote ?
            ("Undo Upvote", Icons.upvoteSquareFill) :
            ("Upvote", Icons.upvoteSquare)
        functions.append(MenuFunction.standardMenuFunction(
            text: upvoteText,
            imageName: upvoteImg
        ) {
            Task(priority: .userInitiated) {
                await upvote()
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = hierarchicalComment.commentView.myVote == .downvote ?
            ("Undo Downvote", Icons.downvoteSquareFill) :
            ("Downvote", Icons.downvoteSquare)
        functions.append(MenuFunction.standardMenuFunction(
            text: downvoteText,
            imageName: downvoteImg
        ) {
            Task(priority: .userInitiated) {
                await downvote()
            }
        })
                
        // save
        let (saveText, saveImg) = hierarchicalComment.commentView.saved ?
            ("Unsave", Icons.saveFill) :
            ("Save", Icons.save)
        functions.append(MenuFunction.standardMenuFunction(
            text: saveText,
            imageName: saveImg
        ) {
            Task(priority: .userInitiated) {
                await saveComment()
            }
        })

        // reply
        functions.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply
        ) {
            replyToComment()
        })
        
        let content = hierarchicalComment.commentView.comment.content
        functions.append(MenuFunction.standardMenuFunction(
            text: "Select Text",
            imageName: Icons.select
        ) {
            editorTracker.openEditor(with: SelectTextModel(text: content))
        })
        
        let isOwnComment = appState.isCurrentAccountId(hierarchicalComment.commentView.creator.id)
        
        if isOwnComment {
            // edit
            functions.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit
            ) {
                editComment()
            })
        
            // delete
            functions.append(MenuFunction.standardMenuFunction(
                text: "Delete",
                imageName: Icons.delete,
                confirmationPrompt: "Are you sure you want to delete this comment?  This cannot be undone.",
                enabled: !hierarchicalComment.commentView.comment.deleted
            ) {
                Task(priority: .userInitiated) {
                    await deleteComment()
                }
            })
        }
                
        // share
        if let url = URL(string: hierarchicalComment.commentView.comment.apId) {
            functions.append(MenuFunction.shareMenuFunction(url: url))
        }
        
        if !isOwnComment {
            if !isMod {
                // report
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Report",
                    imageName: Icons.moderationReport,
                    isDestructive: true
                ) {
                    editorTracker.openEditor(with: ConcreteEditorModel(
                        comment: hierarchicalComment.commentView,
                        operation: CommentOperation.reportComment
                    ))
                })
            }
            
            // block
            functions.append(MenuFunction.standardMenuFunction(
                text: "Block User",
                imageName: Icons.hide,
                confirmationPrompt: AppConstants.blockUserPrompt
            ) {
                Task(priority: .userInitiated) {
                    await blockUser(userId: hierarchicalComment.commentView.creator.id)
                }
            })
        }
                
        return [.controlGroupMenuFunction(children: functions)]
    }
    
    func modMenuFunctions(community: CommunityModel?) -> [MenuFunction] {
        let isOwnComment = appState.isCurrentAccountId(hierarchicalComment.commentView.creator.id)
        let creator: UserModel = .init(from: hierarchicalComment.commentView.creator)
        
        var functions: [MenuFunction] = .init()
        
        // TODO: 0.19 deprecation
        if siteInformation.isAdmin || ((siteInformation.version ?? .infinity) > .init("0.19.3")) {
            functions.append(.navigationMenuFunction(
                text: "View Votes",
                imageName: Icons.votes,
                destination: .commentVotes(hierarchicalComment)
            ))
        }
        
        if let community, siteInformation.canModerate(user: creator, in: community.communityId) {
            functions.append(.toggleableMenuFunction(
                toggle: hierarchicalComment.commentView.comment.removed,
                trueText: "Restore",
                trueImageName: Icons.restore,
                falseText: "Remove",
                falseImageName: Icons.remove,
                isDestructive: .whenFalse
            ) {
                modToolTracker.removeComment(
                    hierarchicalComment,
                    shouldRemove: !self.hierarchicalComment.commentView.comment.removed
                )
            })
        }
        
        if creator.canBeAdministrated() {
            functions.append(.standardMenuFunction(
                text: "Purge",
                imageName: Icons.purge,
                isDestructive: true
            ) {
                modToolTracker.purgeContent(
                    hierarchicalComment,
                    userRemovalWalker: .init(commentTracker: commentTracker)
                )
            })
            functions.append(.divider)
        }
        
        if let community, siteInformation.canModerate(user: creator, in: community.communityId) {
            let creatorBannedFromCommunity = hierarchicalComment.commentView.creatorBannedFromCommunity
            let creatorBannedFromInstance = hierarchicalComment.commentView.creator.banned
            
            // for admins, default to instance ban iff not a moderator of this community
            if siteInformation.isAdmin, !siteInformation.isMod(communityId: hierarchicalComment.commentView.community.id) {
                functions.append(MenuFunction.toggleableMenuFunction(
                    toggle: creatorBannedFromInstance,
                    trueText: "Unban User",
                    trueImageName: Icons.instanceUnban,
                    falseText: "Ban User",
                    falseImageName: Icons.instanceBan,
                    isDestructive: .whenFalse
                ) {
                    modToolTracker.banUser(
                        .init(from: hierarchicalComment.commentView.creator),
                        from: .init(from: hierarchicalComment.commentView.community),
                        bannedFromCommunity: creatorBannedFromCommunity,
                        shouldBan: !creatorBannedFromInstance,
                        userRemovalWalker: .init(commentTracker: commentTracker)
                    )
                })
            } else {
                functions.append(MenuFunction.toggleableMenuFunction(
                    toggle: creatorBannedFromCommunity,
                    trueText: "Unban User",
                    trueImageName: Icons.communityUnban,
                    falseText: "Ban User",
                    falseImageName: Icons.communityBan,
                    isDestructive: .whenFalse
                ) {
                    modToolTracker.banUser(
                        .init(from: hierarchicalComment.commentView.creator),
                        from: .init(from: hierarchicalComment.commentView.community),
                        bannedFromCommunity: creatorBannedFromCommunity,
                        shouldBan: !creatorBannedFromCommunity,
                        userRemovalWalker: .init(commentTracker: commentTracker)
                    )
                })
            }
            
            if siteInformation.isAdmin {
                functions.append(.standardMenuFunction(
                    text: "Purge User",
                    imageName: Icons.purge,
                    isDestructive: true
                ) {
                    modToolTracker.purgeContent(
                        UserModel(from: hierarchicalComment.commentView.creator),
                        userRemovalWalker: .init(commentTracker: commentTracker)
                    )
                })
            }
        }
        
        return functions
    }
}

// swiftlint:enable function_body_length
