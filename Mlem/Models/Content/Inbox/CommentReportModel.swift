//
//  CommentReportModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation
import Dependencies

class CommentReportModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    var reporter: UserModel
    var resolver: UserModel?
    @Published var commentCreator: UserModel
    var community: CommunityModel
    var commentReport: APICommentReport
    @Published var comment: APIComment
    @Published var votes: VotesModel
    @Published var numReplies: Int
    @Published var creatorBannedFromCommunity: Bool
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
        creatorBannedFromCommunity: Bool
    ) {
        self.reporter = reporter
        self.resolver = resolver
        self.commentCreator = commentCreator
        self.community = community
        self.commentReport = commentReport
        self.comment = comment
        self.votes = votes
        self.numReplies = numReplies
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.purged = false
    }
    
    @MainActor
    func reinit(from commentReport: CommentReportModel) {
        self.reporter = commentReport.reporter
        self.resolver = commentReport.resolver
        self.commentCreator = commentReport.commentCreator
        self.community = commentReport.community
        self.commentReport = commentReport.commentReport
        self.comment = commentReport.comment
        self.votes = commentReport.votes
        self.numReplies = commentReport.numReplies
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.purged = commentReport.purged
    }
    
    func toggleResolved() async throws {
        hapticManager.play(haptic: .lightSuccess, priority: .low)
        let response = try await apiClient.markCommentReportResolved(reportId: commentReport.id, resolved: !commentReport.resolved)
        await reinit(from: response)
    }
    
    func removeComment(modToolTracker: ModToolTracker, shouldRemove: Bool) {
        modToolTracker.removeComment(self, shouldRemove: shouldRemove)
    }
    
    func toggleCommentCreatorBanned(modToolTracker: ModToolTracker, inboxTracker: InboxTracker) {
        modToolTracker.banUser(
            commentCreator,
            from: community,
            bannedFromCommunity: creatorBannedFromCommunity,
            shouldBan: !creatorBannedFromCommunity,
            userRemovalWalker: .init(inboxTracker: inboxTracker)
        )
    }
}

extension CommentReportModel: Removable {
    var removalId: Int { comment.id }
    var removed: Bool {
        get { comment.removed }
        set { comment.removed = newValue }
    }
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
