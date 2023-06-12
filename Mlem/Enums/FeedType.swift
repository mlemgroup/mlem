//
//  FeedType.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

enum FeedType: String, Encodable
{
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
}
