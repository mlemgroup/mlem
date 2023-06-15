//
//  APILanguage.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023
//

import Foundation

// lemmy_db_schema::source::language::Language
struct APILanguage: Decodable {
    let id: Int
    let code: String
    let name: String
}
