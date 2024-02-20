//
//  CreatePostReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreatePostReportRequest: APIPostRequest {
    typealias Body = APICreatePostReport
    typealias Response = APIPostReportResponse

    let path = "/post/report"
    let body: Body?

    init(
        postId: Int,
        reason: String
    ) {
        self.body = .init(
            postId: postId,
            reason: reason
        )
    }
}
