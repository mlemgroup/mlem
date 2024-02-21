//
//  ApiGetReportCountResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetReportCountResponse.ts
struct ApiGetReportCountResponse: Codable {
    let communityId: Int?
    let commentReports: Int
    let postReports: Int
    let privateMessageReports: Int?
}
