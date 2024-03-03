//
//  PostModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 27/01/2024.
//

import Foundation

extension PostModel {
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_parameter_count
    
    /// Produces menu functions for this post
    /// - Parameters:
    ///   - editorTracker: global EditorTracker
    ///   - postTracker: optional StandardPostTracker. If present, the block function will remove posts from the tracker by the blocked user.
    ///   - community: optional CommunityModel. If this and modToolTracker are present, moderator functions will be included in the menu.
    ///   - modToolTracker: optional ModToolTracker. If this and community are present, moderator functions will be included in the menu.
    ///   - Returns: menu functions for this post
    @MainActor func menuFunctions(
        editorTracker: EditorTracker,
        showExtraContextMenuActions: Bool,
        widgetTracker: LayoutWidgetTracker,
        postTracker: StandardPostTracker?,
        community: CommunityModel?,
        modToolTracker: ModToolTracker?
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
        let widgets = widgetTracker.groups.post
        
        if showExtraContextMenuActions || LayoutWidgetType.upvoteContaining.isDisjoint(with: widgets) {
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
        }

        if showExtraContextMenuActions || LayoutWidgetType.downvoteContaining.isDisjoint(with: widgets) {
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
        }
        
        if showExtraContextMenuActions || !widgets.contains(.save) {
            // Save
            functions.append(MenuFunction.standardMenuFunction(
                text: saved ? "Unsave" : "Save",
                imageName: saved ? Icons.unsave : Icons.save,
                enabled: true
            ) {
                Task(priority: .userInitiated) {
                    await self.toggleSave()
                }
            })
        }
        
        if showExtraContextMenuActions || !widgets.contains(.reply) {
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
        }
        
        if creator.isActiveAccount {
            // Edit
            functions.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit,
                enabled: true
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
        
        if showExtraContextMenuActions || !widgets.contains(.share) {
            // Share
            if let url = URL(string: post.apId) {
                functions.append(MenuFunction.shareMenuFunction(url: url))
            }
        }
        
        if modToolTracker == nil, !creator.isActiveAccount {
            if modToolTracker == nil {
                // Report
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Report",
                    imageName: Icons.moderationReport,
                    confirmationPrompt: AppConstants.reportPostPrompt
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
        
        if let community, let modToolTracker {
            functions.append(.divider)
            functions.append(
                contentsOf: modMenuFunctions(
                    community: community,
                    modToolTracker: modToolTracker,
                    postTracker: postTracker
                )
            )
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

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_parameter_count
    
    // swiftlint:disable:next function_body_length
    private func modMenuFunctions(
        community: CommunityModel,
        modToolTracker: ModToolTracker,
        postTracker: StandardPostTracker?
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
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
        
        functions.append(MenuFunction.toggleableMenuFunction(
            toggle: post.removed,
            trueText: "Restore",
            trueImageName: Icons.restore,
            falseText: "Remove",
            falseImageName: Icons.remove,
            isDestructive: .always
        ) {
            modToolTracker.removePost(self, shouldRemove: !self.post.removed)
        })

        if creator.userId != siteInformation.userId {
            functions.append(MenuFunction.toggleableMenuFunction(
                toggle: creatorBannedFromCommunity,
                trueText: "Unban User",
                trueImageName: Icons.communityUnban,
                falseText: "Ban User",
                falseImageName: Icons.communityBan,
                isDestructive: .whenFalse
            ) {
                modToolTracker.banUserFromCommunity(
                    self.creator,
                    from: community,
                    shouldBan: !self.creatorBannedFromCommunity,
                    postTracker: postTracker
                )
            })
        }
        
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
        if !(self.community.blocked ?? true) && !self.creator.blocked {
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
            if self.creator.blocked {
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
            if self.community.blocked ?? false {
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
