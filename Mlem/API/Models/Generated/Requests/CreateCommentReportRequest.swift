//
//  CreateCommentReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreateCommentReportRequest: ApiPostRequest {
    typealias Body = ApiCreateCommentReport
    typealias Response = ApiCommentReportResponse

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
