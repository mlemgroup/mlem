//
//  ResolvePostReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
          reportId: reportId,
          resolved: resolved
      )
    }
}
