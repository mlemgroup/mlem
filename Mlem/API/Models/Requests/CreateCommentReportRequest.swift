//
//  CreateCommentReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct CreateCommentReportRequest: APIPostRequest {
    typealias Body = APICreateCommentReport
    typealias Response = APICommentReportResponse

    let path = "/comment/report"
    let body: Body?

    init(
        commentId: Int,
        reason: String
    ) {
        self.body = .init(
            comment_id: commentId,
            reason: reason
        )
    }
}
