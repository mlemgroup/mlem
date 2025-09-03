//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-11.
//

import Foundation

public enum ListingType: String, CaseIterable, Codable {
    case all, local, subscribed, moderated, popular, suggested
}
