//
//  ResolvePostReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct ResolvePostReportRequest: APIPutRequest {
    typealias Response = APIPostReportResponse
    
    let instanceURL: URL
    let path = "post/report/resolve"
    let body: Body
    
    struct Body: Encodable {
        let auth: String
        let report_id: Int
        let resolved: Bool
    }
    
    init(
        session: APISession,
        reportId: Int,
        resolved: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            auth: session.token,
            report_id: reportId,
            resolved: resolved
        )
    }
}

struct APIPostReportResponse: Decodable {
    let postReportView: APIPostReportView
}
