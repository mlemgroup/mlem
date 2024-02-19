//
//  APIGetReportCountResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetReportCountResponse.ts
struct APIGetReportCountResponse: Codable {
    let community_id: Int?
    let comment_reports: Int
    let post_reports: Int
    let private_message_reports: Int?
}
