//
//  CreatePostReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            post_id: postId,
            reason: reason
        )
    }
}
