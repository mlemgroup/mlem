//
//  Favorite Community.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

struct FavoriteCommunity: Identifiable, Codable, Equatable {
    var id: UUID = UUID()

    let forAccountID: Int

    let community: APICommunity
}

extension FavoriteCommunity: Comparable {
    static func < (lhs: FavoriteCommunity, rhs: FavoriteCommunity) -> Bool {
        return lhs.community < rhs.community
    }
}
