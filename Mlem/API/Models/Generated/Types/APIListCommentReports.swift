//
//  APIListCommentReports.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ListCommentReports.ts
struct APIListCommentReports: Codable {
    let page: Int?
    let limit: Int?
    let unresolvedOnly: Bool?
    let communityId: Int?
}
