//
//  ResolvePostReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ResolvePostReportRequest: APIPutRequest {
    typealias Body = APIResolvePostReport
    typealias Response = APIPostReportResponse

    let path = "/post/report/resolve"
    let body: Body?

    init(
        reportId: Int,
        resolved: Bool
    ) {
        self.body = .init(
            report_id: reportId,
            resolved: resolved
        )
    }
}
