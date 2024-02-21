//
//  ResolveCommentReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ResolveCommentReportRequest: ApiPutRequest {
    typealias Body = ApiResolveCommentReport
    typealias Response = ApiCommentReportResponse

    let path = "/comment/report/resolve"
    let body: Body?

    init(
        reportId: Int,
        resolved: Bool
    ) {
        self.body = .init(
            reportId: reportId,
            resolved: resolved
        )
    }
}
