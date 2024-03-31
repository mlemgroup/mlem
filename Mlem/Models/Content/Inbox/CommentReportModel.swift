//
//  CommentReportModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation

class CommentReportModel: ContentIdentifiable, ObservableObject {
    let reporter: UserModel
    let community: CommunityModel
    let commentReport: APICommentReport
    @Published var comment: APIComment
    @Published var votes: VotesModel
    @Published var numReplies: Int
    @Published var purged: Bool
    
    var uid: ContentModelIdentifier { .init(contentType: .commentReport, contentId: commentReport.id) }
    
    init(
        reporter: UserModel,
        community: CommunityModel,
        commentReport: APICommentReport,
        comment: APIComment,
        votes: VotesModel,
        numReplies: Int
    ) {
        self.reporter = reporter
        self.community = community
        self.commentReport = commentReport
        self.comment = comment
        self.votes = votes
        self.numReplies = numReplies
        self.purged = false
    }
    
    func remove(modToolTracker: ModToolTracker) {
        modToolTracker.removeComment(self, shouldRemove: true)
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
