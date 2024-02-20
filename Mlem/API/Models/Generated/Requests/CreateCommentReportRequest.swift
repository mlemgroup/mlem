//
//  CreateCommentReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            commentId: commentId,
            reason: reason
        )
    }
}
