//
//  CommentReportModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Dependencies
import Foundation

class CommentReportModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    var reporter: UserModel
    var resolver: UserModel?
    @Published var commentCreator: UserModel
    var community: CommunityModel
    var commentReport: APICommentReport
    @Published var comment: APIComment
    @Published var votes: VotesModel
    @Published var numReplies: Int
    @Published var commentCreatorBannedFromCommunity: Bool
    @Published var purged: Bool
    
    var uid: ContentModelIdentifier { .init(contentType: .commentReport, contentId: commentReport.id) }
    
    init(
        reporter: UserModel,
        resolver: UserModel?,
        commentCreator: UserModel,
        community: CommunityModel,
        commentReport: APICommentReport,
        comment: APIComment,
        votes: VotesModel,
        numReplies: Int,
        commentCreatorBannedFromCommunity: Bool
    ) {
        self.reporter = reporter
        self.resolver = resolver
        self.commentCreator = commentCreator
        self.community = community
        self.commentReport = commentReport
        self.comment = comment
        self.votes = votes
        self.numReplies = numReplies
        self.commentCreatorBannedFromCommunity = commentCreatorBannedFromCommunity
        self.purged = false
    }
    
    @MainActor
    func reinit(from commentReport: CommentReportModel) {
        reporter = commentReport.reporter
        resolver = commentReport.resolver
        commentCreator = commentReport.commentCreator
        community = commentReport.community
        self.commentReport = commentReport.commentReport
        comment = commentReport.comment
        votes = commentReport.votes
        numReplies = commentReport.numReplies
        commentCreatorBannedFromCommunity = commentCreatorBannedFromCommunity
        purged = commentReport.purged
    }
    
    @MainActor
    func setPurged(_ newPurged: Bool) {
        purged = newPurged
    }
    
    func toggleResolved(unreadTracker: UnreadTracker, withHaptic: Bool = true) async {
        let originalReadState: Bool = read
        
        if withHaptic {
            hapticManager.play(haptic: .lightSuccess, priority: .low)
        }
        do {
            let response = try await apiClient.markCommentReportResolved(reportId: commentReport.id, resolved: !commentReport.resolved)
            await reinit(from: response)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                unreadTracker.commentReports.toggleRead(originalState: originalReadState)
            }
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func toggleCommentRemoved(modToolTracker: ModToolTracker, unreadTracker: UnreadTracker) {
        modToolTracker.removeComment(self, shouldRemove: !comment.removed) {
            if !self.read {
                Task {
                    await self.toggleResolved(unreadTracker: unreadTracker, withHaptic: false)
                }
            }
        }
    }
    
    func toggleCommentCreatorBanned(modToolTracker: ModToolTracker, inboxTracker: InboxTracker, unreadTracker: UnreadTracker) {
        modToolTracker.banUser(
            commentCreator,
            from: community,
            bannedFromCommunity: commentCreatorBannedFromCommunity,
            shouldBan: !commentCreatorBannedFromCommunity,
            userRemovalWalker: .init(inboxTracker: inboxTracker)
        ) {
            if !self.read {
                Task(priority: .userInitiated) {
                    await self.toggleResolved(unreadTracker: unreadTracker, withHaptic: false)
                }
            }
        }
    }
    
    func purgeComment(modToolTracker: ModToolTracker) {
        modToolTracker.purgeContent(self)
    }
    
    func genMenuFunctions(modToolTracker: ModToolTracker, inboxTracker: InboxTracker, unreadTracker: UnreadTracker) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        ret.append(.toggleableMenuFunction(
            toggle: commentReport.resolved,
            trueText: "Unresolve",
            trueImageName: Icons.unresolve,
            falseText: "Resolve",
            falseImageName: Icons.resolve
        ) {
            Task(priority: .userInitiated) {
                await self.toggleResolved(unreadTracker: unreadTracker)
            }
        }
        )
        
        ret.append(.toggleableMenuFunction(
            toggle: comment.removed,
            trueText: "Restore",
            trueImageName: Icons.restore,
            falseText: "Remove",
            falseImageName: Icons.remove,
            isDestructive: .whenFalse
        ) {
            self.toggleCommentRemoved(modToolTracker: modToolTracker, unreadTracker: unreadTracker)
        }
        )
        
        ret.append(.toggleableMenuFunction(
            toggle: commentCreatorBannedFromCommunity,
            trueText: "Unban",
            trueImageName: Icons.communityUnban,
            falseText: "Ban",
            falseImageName: Icons.communityBan,
            isDestructive: .whenFalse
        ) {
            self.toggleCommentCreatorBanned(
                modToolTracker: modToolTracker,
                inboxTracker: inboxTracker,
                unreadTracker: unreadTracker
            )
        }
        )
        
        ret.append(.standardMenuFunction(
            text: "Purge",
            imageName: Icons.purge,
            isDestructive: true
        ) {
            self.purgeComment(modToolTracker: modToolTracker)
        }
        )
        
        return ret
    }
    
    func swipeActions(
        modToolTracker: ModToolTracker,
        inboxTracker: InboxTracker,
        unreadTracker: UnreadTracker
    ) -> SwipeConfiguration {
        var leadingActions: [SwipeAction] = .init()
        var trailingActions: [SwipeAction] = .init()
        
        leadingActions.append(SwipeAction(
            symbol: .init(
                emptyName: read ? Icons.resolveFill : Icons.resolve,
                fillName: read ? Icons.resolve : Icons.resolveFill
            ),
            color: .green
        ) {
            Task(priority: .userInitiated) {
                await self.toggleResolved(unreadTracker: unreadTracker)
            }
        })
        leadingActions.append(SwipeAction(
            symbol: .init(
                emptyName: comment.removed ? Icons.restore : Icons.remove,
                fillName: comment.removed ? Icons.restoreFill : Icons.removeFill
            ),
            color: .red
        ) {
            self.toggleCommentRemoved(modToolTracker: modToolTracker, unreadTracker: unreadTracker)
        })
        
        trailingActions.append(SwipeAction(
            symbol: .init(
                emptyName: creatorBannedFromCommunity ? Icons.communityUnban : Icons.communityBan,
                fillName: creatorBannedFromCommunity ? Icons.communityUnbanned : Icons.communityBanFill
            ),
            color: .red
        ) {
            self.toggleCommentCreatorBanned(
                modToolTracker: modToolTracker,
                inboxTracker: inboxTracker,
                unreadTracker: unreadTracker
            )
        })
        
        if siteInformation.isAdmin {
            trailingActions.append(SwipeAction(
                symbol: .init(emptyName: Icons.purge, fillName: Icons.purge),
                color: .primary,
                iconColor: .systemBackground
            ) {
                modToolTracker.purgeContent(self)
            })
        }
        
        return SwipeConfiguration(leadingActions: leadingActions, trailingActions: trailingActions)
    }
}

extension CommentReportModel: Removable, Purgable {
    func remove(reason: String?, shouldRemove: Bool) async -> Bool {
        do {
            let response = try await apiClient.removeComment(
                id: comment.id,
                shouldRemove: shouldRemove,
                reason: reason
            )
            if response.commentView.comment.removed == shouldRemove {
                await MainActor.run {
                    self.comment.removed = shouldRemove
                }
            }
            return true
        } catch {
            errorHandler.handle(error)
        }
        return false
    }
    
    func purge(reason: String?) async -> Bool {
        do {
            let response = try await apiClient.purgeComment(id: comment.id, reason: reason)
            if response.success {
                await setPurged(true)
                // don't need to actually call toggleResolved()--purge removes the report altogether, but this is less jarring than removing it from feed
                await MainActor.run {
                    self.commentReport.resolved = true
                }
                return true
            }
        } catch {
            errorHandler.handle(error)
        }
        return false
    }
    
    func canBeAdministrated() -> Bool { true }
}

extension CommentReportModel: Hashable, Equatable {
    static func == (lhs: CommentReportModel, rhs: CommentReportModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(reporter)
        hasher.combine(commentReport)
        hasher.combine(comment)
        hasher.combine(votes)
        hasher.combine(numReplies)
    }
}
