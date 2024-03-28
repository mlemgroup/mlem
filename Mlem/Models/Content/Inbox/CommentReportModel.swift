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
    
    var uid: ContentModelIdentifier { .init(contentType: .commentReport, contentId: commentReport.id) }
    
    init(reporter: UserModel, community: CommunityModel, commentReport: APICommentReport, comment: APIComment) {
        self.reporter = reporter
        self.community = community
        self.commentReport = commentReport
        self.comment = comment
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
    }
}
