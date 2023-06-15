//
//  APITagline.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023
//

import Foundation

// lemmy_db_schema::source::tagline::Tagline
struct APITagline: Decodable {
    let id: Int
    let localSiteId: Int
    let content: String
    let published: Date
    let updated: Date?
}
