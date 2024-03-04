//
//  PostModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 27/01/2024.
//

import Foundation

extension PostModel {
    // swiftlint:disable function_body_length
    
    /// Produces menu functions for this post
    /// - Parameters:
    ///   - editorTracker: global EditorTracker
    ///   - postTracker: optional StandardPostTracker. If present, the block function will remove posts from the tracker by the blocked user.
    ///   - community: optional CommunityModel. If this and modToolTracker are present, moderator functions will be included in the menu.
    ///   - modToolTracker: optional ModToolTracker. If this and community are present, moderator functions will be included in the menu.
    /// - Returns: menu functions for this post
    func menuFunctions(
        editorTracker: EditorTracker,
        postTracker: StandardPostTracker?,
        community: CommunityModel?,
        modToolTracker: ModToolTracker?
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
//        if let community, let modToolTracker {
//            functions.append(.childMenu(
//                titleKey: "Moderation",
//                children: modMenuFunctions(community: community, modToolTracker: modToolTracker, postTracker: postTracker)
//            )
//            )
//        }
            
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
            imageName: saved ? Icons.unsave : Icons.save,
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
                role: .destructive(prompt: "Are you sure you want to delete this post? This cannot be undone."),
                enabled: !post.deleted
            ) {
                Task(priority: .userInitiated) {
                    await self.delete()
                }
            })
        }
        
        // Share
        if let url = URL(string: post.apId) {
            functions.append(MenuFunction.shareMenuFunction(url: url))
        }
        
        if !creator.isActiveAccount {
            // Report
            functions.append(MenuFunction.standardMenuFunction(
                text: "Report",
                imageName: Icons.moderationReport,
                role: .destructive(prompt: AppConstants.reportPostPrompt),
                enabled: true
            ) {
                editorTracker.openEditor(
                    with: ConcreteEditorModel(post: self, operation: PostOperation.reportPost)
                )
            })
            
            if let postTracker {
                // Block User
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Block User",
                    imageName: Icons.userBlock,
                    role: .destructive(prompt: AppConstants.blockUserPrompt),
                    enabled: true
                ) {
                    Task(priority: .userInitiated) {
                        await self.creator.toggleBlock { self.creator = $0 }
                        if self.creator.blocked {
                            await postTracker.applyFilter(.blockedUser(self.creator.userId))
                            await self.notifier.add(.failure("Blocked \(self.creator.name ?? "user")"))
                        } else {
                            await self.notifier.add(.failure("Failed to block user"))
                        }
                    }
                })
                
                // Block Community
                functions.append(MenuFunction.standardMenuFunction(
                    text: "Block Community",
                    imageName: Icons.hide,
                    role: .destructive(prompt: AppConstants.blockCommunityPrompt),
                    enabled: true
                ) {
                    Task(priority: .userInitiated) {
                        try await self.community.toggleBlock { self.community = $0 }
                        if self.community.blocked ?? false {
                            await postTracker.applyFilter(.blockedCommunity(self.community.communityId))
                            await self.notifier.add(.failure("Blocked \(self.community.name ?? "community")"))
                        } else {
                            await self.notifier.add(.failure("Failed to block community"))
                        }
                    }
                })
            }
        }
        
        if let community, let modToolTracker {
            functions.append(.divider)
            functions.append(contentsOf: modMenuFunctions(community: community, modToolTracker: modToolTracker, postTracker: postTracker))
        }

        #if DEBUG
            functions.append(
                buildDeveloperMenu(
                    editorTracker: editorTracker,
                    postTracker: postTracker
                )
            )
        #endif
        
        return functions
    }

    // swiftlint:enable function_body_length
    
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
            falseRole: .destructive(prompt: nil)
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
                falseRole: .destructive(prompt: nil)
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

    #if DEBUG
        private func buildDeveloperMenu(
            editorTracker: EditorTracker,
            postTracker: StandardPostTracker?
        ) -> MenuFunction {
            MenuFunction.childMenu(
                titleKey: "Developer Menu",
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
