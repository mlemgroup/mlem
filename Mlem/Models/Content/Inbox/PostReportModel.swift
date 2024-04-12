//
//  PostReportModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Dependencies
import Foundation

class PostReportModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    
    var reporter: UserModel
    var resolver: UserModel?
    @Published var postCreator: UserModel
    var community: CommunityModel
    var postReport: APIPostReport
    @Published var post: APIPost
    @Published var votes: VotesModel
    @Published var numReplies: Int
    @Published var postCreatorBannedFromCommunity: Bool
    @Published var purged: Bool
    
    var uid: ContentModelIdentifier { .init(contentType: .postReport, contentId: postReport.id) }
    
    init(
        reporter: UserModel,
        resolver: UserModel?,
        postCreator: UserModel,
        community: CommunityModel,
        postReport: APIPostReport,
        post: APIPost,
        votes: VotesModel,
        numReplies: Int,
        postCreatorBannedFromCommunity: Bool
    ) {
        self.reporter = reporter
        self.resolver = resolver
        self.postCreator = postCreator
        self.community = community
        self.postReport = postReport
        self.post = post
        self.votes = votes
        self.numReplies = numReplies
        self.postCreatorBannedFromCommunity = postCreatorBannedFromCommunity
        self.purged = false
    }
    
    @MainActor
    func reinit(from postReport: PostReportModel) {
        reporter = postReport.reporter
        resolver = postReport.resolver
        postCreator = postReport.postCreator
        community = postReport.community
        self.postReport = postReport.postReport
        post = postReport.post
        votes = postReport.votes
        numReplies = postReport.numReplies
        postCreatorBannedFromCommunity = postReport.postCreatorBannedFromCommunity
        purged = postReport.purged
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
            let response = try await apiClient.markPostReportResolved(reportId: postReport.id, resolved: !postReport.resolved)
            await reinit(from: response)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                unreadTracker.postReports.toggleRead(originalState: originalReadState)
            }
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func togglePostRemoved(modToolTracker: ModToolTracker, unreadTracker: UnreadTracker) {
        modToolTracker.removePost(self, shouldRemove: !post.removed) {
            if !self.read {
                Task {
                    await self.toggleResolved(unreadTracker: unreadTracker, withHaptic: false)
                }
            }
        }
    }
    
    func togglePostCreatorBanned(modToolTracker: ModToolTracker, inboxTracker: InboxTracker, unreadTracker: UnreadTracker) {
        modToolTracker.banUser(
            postCreator,
            from: community,
            bannedFromCommunity: postCreatorBannedFromCommunity,
            shouldBan: !postCreatorBannedFromCommunity,
            userRemovalWalker: .init(inboxTracker: inboxTracker)
        ) {
            if !self.postReport.resolved {
                Task(priority: .userInitiated) {
                    await self.toggleResolved(unreadTracker: unreadTracker, withHaptic: false)
                }
            }
        }
    }
    
    func purgePost(modToolTracker: ModToolTracker) {
        modToolTracker.purgeContent(self)
    }
    
    func genMenuFunctions(
        modToolTracker: ModToolTracker,
        inboxTracker: InboxTracker,
        unreadTracker: UnreadTracker
    ) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        ret.append(.toggleableMenuFunction(
            toggle: postReport.resolved,
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
            toggle: post.removed,
            trueText: "Restore",
            trueImageName: Icons.restore,
            falseText: "Remove",
            falseImageName: Icons.remove,
            isDestructive: .whenFalse
        ) {
            self.togglePostRemoved(modToolTracker: modToolTracker, unreadTracker: unreadTracker)
        }
        )
        
        ret.append(.toggleableMenuFunction(
            toggle: creatorBannedFromCommunity,
            trueText: "Unban",
            trueImageName: Icons.communityUnban,
            falseText: "Ban",
            falseImageName: Icons.communityBan,
            isDestructive: .whenFalse
        ) {
            self.togglePostCreatorBanned(modToolTracker: modToolTracker, inboxTracker: inboxTracker, unreadTracker: unreadTracker)
        }
        )
        
        ret.append(.standardMenuFunction(
            text: "Purge",
            imageName: Icons.purge,
            isDestructive: true
        ) {
            self.purgePost(modToolTracker: modToolTracker)
        }
        )
        
        return ret
    }
}

extension PostReportModel: Hashable, Equatable {
    static func == (lhs: PostReportModel, rhs: PostReportModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(reporter)
        hasher.combine(postReport)
        hasher.combine(post)
        hasher.combine(votes)
        hasher.combine(numReplies)
    }
}

extension PostReportModel: Removable, Purgable {
    func remove(reason: String?, shouldRemove: Bool) async -> Bool {
        do {
            let response = try await apiClient.removePost(id: post.id, shouldRemove: shouldRemove, reason: reason)
            if response.post.removed == shouldRemove {
                await MainActor.run {
                    self.post.removed = shouldRemove
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
            let response = try await apiClient.purgePost(id: post.id, reason: reason)
            if response.success {
                await setPurged(true)
                await MainActor.run {
                    self.postReport.resolved = true
                }
                return true
            }
        } catch {
            errorHandler.handle(error)
        }
        return false
    }
}
