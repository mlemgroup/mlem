//
//  APIVoteView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/VoteView.ts
struct APIVoteView: Codable {
    let creator: APIPerson
    let score: Int

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
