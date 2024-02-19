//
//  ResolvePrivateMessageReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ResolvePrivateMessageReportRequest: APIPutRequest {
    typealias Body = APIResolvePrivateMessageReport
    typealias Response = APIPrivateMessageReportResponse

    let path = "/private_message/report/resolve"
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
