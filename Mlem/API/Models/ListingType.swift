//
//  ListingType.swift
//  Mlem
//
//  Created by Sjmarf on 25/11/2023.
//

import Foundation

enum APIListingType: String, Codable {
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
    case moderatorView = "ModeratorView"
}
