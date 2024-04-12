//
//  PostModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 27/01/2024.
//

import Foundation
import SwiftUI

// swiftlint:disable file_length

extension PostModel {
    // swiftlint:disable function_body_length
    /// Produces menu functions for this post
    /// - Parameters:
    ///   - editorTracker: global EditorTracker
    ///   - postTracker: optional StandardPostTracker. If present, the block function will remove posts from the tracker by the blocked user.
    ///   - community: optional CommunityModel. If this and modToolTracker are present, moderator functions will be included in the menu.
    ///   - modToolTracker: optional ModToolTracker. If this and community are present, moderator functions will be included in the menu.
    ///   - Returns: menu functions for this post
    @MainActor func combinedMenuFunctions(
        isExpanded: Bool = false,
        editorTracker: EditorTracker,
        showSelectText: Bool = true,
        postTracker: StandardPostTracker? = nil,
        commentTracker: CommentTracker? = nil,
        community: CommunityModel? = nil,
        modToolTracker: ModToolTracker? = nil
    ) -> [MenuFunction] {
        @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
        
        var functions: [MenuFunction] = .init()

        functions.append(
            contentsOf: personalMenuFunctions(
                editorTracker: editorTracker,
                showSelectText: showSelectText,
                postTracker: postTracker,
                community: community,
                modToolTracker: modToolTracker
            )
        )
        
        if let community, let modToolTracker {
            functions.append(.divider)
            let modFunctions = modMenuFunctions(
                isExpanded: isExpanded,
                community: community,
                modToolTracker: modToolTracker,
                postTracker: postTracker,
                commentTracker: commentTracker
            )
            if !isExpanded, moderatorActionGrouping != .none {
                functions.append(
                    .groupMenuFunction(text: "Moderation", imageName: Icons.moderation, children: modFunctions)
                )
            } else {
                functions.append(contentsOf: modFunctions)
            }
        }
        
        #if DEBUG
            if UserDefaults.standard.bool(forKey: "developerMode") {
                functions.append(.divider)
                functions.append(
                    buildDeveloperMenu(
                        editorTracker: editorTracker,
                        postTracker: postTracker
                    )
                )
            }
        #endif
        
        return functions
    }
    
    @MainActor func personalMenuFunctions(
        editorTracker: EditorTracker,
        showSelectText: Bool = true,
        postTracker: StandardPostTracker? = nil,
        community: CommunityModel? = nil,
        modToolTracker: ModToolTracker? = nil
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
        functions.append(contentsOf: topRowMenuFunctions(editorTracker: editorTracker))
        
        if showSelectText {
            var text = post.name
            if let body = post.body, body.isNotEmpty {
                text += "\n\n\(body)"
            }
            functions.append(MenuFunction.standardMenuFunction(
                text: "Select Text",
                imageName: Icons.select
            ) {
                editorTracker.openEditor(with: SelectTextModel(text: text))
            })
        }
        
        if creator.isActiveAccount {
            // Edit
            functions.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit
            ) {
                editorTracker.openEditor(with: PostEditorModel(post: self))
            })
            
            // Delete
            functions.append(MenuFunction.standardMenuFunction(
                text: "Delete",
                imageName: Icons.delete,
                confirmationPrompt: "Are you sure you want to delete this post? This cannot be undone.",
                enabled: !post.deleted
            ) {
                Task(priority: .userInitiated) {
                    await self.delete()
                }
            })
        }
        
        // Share
        functions.append(MenuFunction.shareMenuFunction(url: post.apId))
        
        if !creator.isActiveAccount {
            if modToolTracker == nil {
                // Report
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Report",
                    imageName: Icons.moderationReport,
                    isDestructive: true
                ) {
                    editorTracker.openEditor(
                        with: ConcreteEditorModel(post: self, operation: PostOperation.reportPost)
                    )
                })
            }
            
            if let postTracker {
                functions.append(contentsOf: blockMenuFunctions(postTracker: postTracker))
            }
        }
        
        return [.controlGroupMenuFunction(children: functions)]
    }

    @MainActor func modMenuFunctions(
        isExpanded: Bool = false,
        community: CommunityModel,
        modToolTracker: ModToolTracker,
        postTracker: StandardPostTracker? = nil,
        commentTracker: CommentTracker? = nil
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
        var showAllActions = isExpanded || UserDefaults.standard.bool(forKey: "showAllModeratorActions")
        @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
        
        if showAllActions {
            if siteInformation.isAdmin {
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Pin",
                    imageName: Icons.pin,
                    prompt: "Pin/Unpin from...",
                    actions: [
                        .init(text: "Community") {
                            Task {
                                await self.toggleFeatured(featureType: .community)
                                await self.notifier.add(.success("\(self.post.featuredCommunity ? "P" : "Unp")inned post"))
                            }
                        },
                        .init(text: "Instance") {
                            Task {
                                await self.toggleFeatured(featureType: .local)
                                await self.notifier.add(.success("\(self.post.featuredLocal ? "P" : "Unp")inned post"))
                            }
                        }
                    ]
                ))
            } else {
                functions.append(MenuFunction.toggleableMenuFunction(
                    toggle: post.featuredCommunity,
                    trueText: "Unpin",
                    trueImageName: Icons.unpin,
                    falseText: "Pin",
                    falseImageName: Icons.pin
                ) {
                    Task {
                        await self.toggleFeatured(featureType: .community)
                        await self.notifier.add(.success("\(self.post.featuredCommunity ? "P" : "Unp")inned post"))
                    }
                })
            }
            
            functions.append(MenuFunction.toggleableMenuFunction(
                toggle: post.locked,
                trueText: "Unlock",
                trueImageName: Icons.unlock,
                falseText: "Lock",
                falseImageName: Icons.lock
            ) {
                Task {
                    await self.toggleLocked()
                    await self.notifier.add(.success("\(self.post.locked ? "L" : "Unl")ocked post"))
                }
            })
            
            // TODO: 0.19 deprecation
            if siteInformation.isAdmin || ((siteInformation.version ?? .zero) > .init("0.19.3")) {
                functions.append(MenuFunction.navigationMenuFunction(
                    text: "View Votes",
                    imageName: Icons.votes,
                    destination: .postVotes(self)
                ))
            }
        }
        
        if creator.userId != siteInformation.userId {
            functions.append(MenuFunction.toggleableMenuFunction(
                toggle: post.removed,
                trueText: "Restore",
                trueImageName: Icons.restore,
                falseText: "Remove",
                falseImageName: Icons.remove,
                isDestructive: .whenFalse
            ) {
                modToolTracker.removePost(self, shouldRemove: !self.post.removed)
            })
        }
        
        if siteInformation.isAdmin {
            functions.append(MenuFunction.standardMenuFunction(
                text: "Purge",
                imageName: Icons.purge,
                isDestructive: true
            ) {
                modToolTracker.purgeContent(self)
            }
            )
        }
            
        if creator.userId != siteInformation.userId {
            if siteInformation.isAdmin {
                functions.append(.divider)
            }
            
            // for admins, default to instance ban iff not a moderator of this community
            if siteInformation.isAdmin, !siteInformation.moderatedCommunities.contains(community.communityId) {
                functions.append(MenuFunction.toggleableMenuFunction(
                    toggle: creator.banned,
                    trueText: "Unban User",
                    trueImageName: Icons.instanceUnban,
                    falseText: "Ban User",
                    falseImageName: Icons.instanceBan,
                    isDestructive: .whenFalse
                ) {
                    modToolTracker.banUser(
                        self.creator,
                        from: community,
                        bannedFromCommunity: self.creatorBannedFromCommunity,
                        shouldBan: !self.creator.banned,
                        userRemovalWalker: .init(postTracker: postTracker, commentTracker: commentTracker)
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
                        self.creator,
                        from: community,
                        bannedFromCommunity: self.creatorBannedFromCommunity,
                        shouldBan: !self.creatorBannedFromCommunity,
                        userRemovalWalker: .init(postTracker: postTracker, commentTracker: commentTracker)
                    )
                })
            }
            
            if siteInformation.isAdmin {
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Purge User",
                    imageName: Icons.purge,
                    isDestructive: true
                ) {
                    modToolTracker.purgeContent(self.creator)
                }
                )
            }
        }
        
        return functions
    }

    // swiftlint:enable function_body_length
    
    private func topRowMenuFunctions(editorTracker: EditorTracker) -> [MenuFunction] {
        var functions = [MenuFunction]()
        
        // Upvote
        functions.append(MenuFunction.standardMenuFunction(
            text: votes.myVote == .upvote ? "Undo Upvote" : "Upvote",
            imageName: votes.myVote == .upvote ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .upvote)
            }
        })

        // Downvote
        functions.append(MenuFunction.standardMenuFunction(
            text: votes.myVote == .downvote ? "Undo Downvote" : "Downvote",
            imageName: votes.myVote == .downvote ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .downvote)
            }
        })
        
        // Save
        functions.append(MenuFunction.standardMenuFunction(
            text: saved ? "Unsave" : "Save",
            imageName: saved ? Icons.saveFill : Icons.save,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.toggleSave()
            }
        })

        // Reply
        functions.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply,
            enabled: true
        ) {
            editorTracker.openEditor(
                with: ConcreteEditorModel(post: self, operation: PostOperation.replyToPost)
            )
        })
        
        return functions
    }
    
    // swiftlint:disable:next function_body_length
    private func blockMenuFunctions(postTracker: StandardPostTracker) -> [MenuFunction] {
        let blockUserCallback = {
            Task(priority: .userInitiated) {
                await self.creator.toggleBlock { self.creator = $0 }
                if self.creator.blocked {
                    await postTracker.applyFilter(.blockedUser(self.creator.userId))
                    await self.notifier.add(.failure("Blocked \(self.creator.name ?? "user")"))
                } else {
                    await self.notifier.add(.failure("Failed to block user"))
                }
            }
            return ()
        }
        
        let unblockUserCallback = {
            Task(priority: .userInitiated) {
                await self.creator.toggleBlock { self.creator = $0 }
                if !self.creator.blocked {
                    await self.notifier.add(.failure("Unblocked \(self.creator.name ?? "user")"))
                } else {
                    await self.notifier.add(.failure("Failed to unblock user"))
                }
            }
            return ()
        }
        
        let blockCommunityCallback = {
            Task(priority: .userInitiated) {
                try await self.community.toggleBlock { self.community = $0 }
                if self.community.blocked ?? false {
                    await postTracker.applyFilter(.blockedCommunity(self.community.communityId))
                    await self.notifier.add(.failure("Blocked \(self.community.name ?? "community")"))
                } else {
                    await self.notifier.add(.failure("Failed to block community"))
                }
            }
            return ()
        }
        
        let unblockCommunityCallback = {
            Task(priority: .userInitiated) {
                await postTracker.removeFilter(.blockedCommunity(self.community.communityId))
                try await self.community.toggleBlock { self.community = $0 }
                if !(self.community.blocked ?? false) {
                    await self.notifier.add(.failure("Unblocked \(self.community.name ?? "community")"))
                } else {
                    await self.notifier.add(.failure("Failed to unblock community"))
                }
            }
            return ()
        }
        
        var functions: [MenuFunction] = .init()
        if !(community.blocked ?? true), !creator.blocked {
            var blockActions: [MenuFunctionPopup.Action] = [
                .init(text: "Block User", callback: blockUserCallback),
                .init(text: "Block Community", callback: blockCommunityCallback)
            ]
            
            functions.append(
                .standardMenuFunction(
                    text: "Block...",
                    imageName: Icons.hide,
                    isDestructive: true,
                    prompt: "Block User or Community?",
                    actions: blockActions
                )
            )
        } else {
            if creator.blocked {
                functions.append(
                    .standardMenuFunction(
                        text: "Unblock User",
                        imageName: Icons.show,
                        callback: unblockUserCallback
                    )
                )
            } else {
                functions.append(
                    .standardMenuFunction(
                        text: "Block User",
                        imageName: Icons.hide,
                        confirmationPrompt: AppConstants.blockUserPrompt,
                        callback: blockUserCallback
                    )
                )
            }
            if community.blocked ?? false {
                functions.append(
                    .standardMenuFunction(
                        text: "Unblock Community",
                        imageName: Icons.show,
                        callback: unblockCommunityCallback
                    )
                )
            } else {
                functions.append(
                    .standardMenuFunction(
                        text: "Block Community",
                        imageName: Icons.hide,
                        confirmationPrompt: AppConstants.blockCommunityPrompt,
                        callback: blockCommunityCallback
                    )
                )
            }
        }
        return functions
    }

    #if DEBUG
        private func buildDeveloperMenu(
            editorTracker: EditorTracker,
            postTracker: StandardPostTracker?
        ) -> MenuFunction {
            MenuFunction.groupMenuFunction(
                text: "Developer",
                imageName: "wrench",
                children: [
                    .standardMenuFunction(
                        text: "Toggle Read State",
                        imageName: "book.and.wrench",
                        enabled: true,
                        callback: {
                            Task {
                                let newState = !self.read
                                await self.markRead(newState)
                            }
                        }
                    )
                ]
            )
        }
    #endif
}

// swiftlint:enable file_length
