//
//  APIGetReportCountResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/GetReportCountResponse.ts
struct APIGetReportCountResponse: Codable {
    let communityId: Int?
    let commentReports: Int
    let postReports: Int
    let privateMessageReports: Int?
}
