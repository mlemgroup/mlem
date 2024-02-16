//
//  PostModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 27/01/2024.
//

import Foundation

extension PostModel {
    // swiftlint:disable function_body_length
    func menuFunctions(editorTracker: EditorTracker, postTracker: StandardPostTracker?) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
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
        
        return functions
    }

    // swiftlint:enable function_body_length
    
    func modMenuFunctions(community: CommunityModel) -> [MenuFunction] {
        assert(community.isModerator(siteInformation.userId), "modMenuFunctions called but user is not a mod!")
        
        var functions: [MenuFunction] = .init()
        
        let banVerb: String, banIcon: String
        if creatorBannedFromCommunity {
            banVerb = "unban"
            banIcon = Icons.communityUnban
        } else {
            banVerb = "ban"
            banIcon = Icons.communityBan
        }
        functions.append(MenuFunction.standardMenuFunction(
            text: "\(banVerb.capitalized) User",
            imageName: banIcon,
            destructiveActionPrompt: "Really \(banVerb) \(creator.name ?? "this user")?",
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                do {
                    let updatedBannedStatus = try await self.apiClient.banFromCommunity(
                        userId: self.post.creatorId,
                        communityId: community.communityId,
                        ban: !self.creatorBannedFromCommunity
                    )
                        
                    await self.setCreatorBannedFromCommunity(updatedBannedStatus)
                } catch {
                    self.errorHandler.handle(error)
                }
            }
        })
        
        return functions
    }
}
