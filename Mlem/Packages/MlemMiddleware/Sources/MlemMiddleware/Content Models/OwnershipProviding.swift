//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-17.
//

import Foundation

public protocol OwnershipProviding: ContentIdentifiable {
    func isOwnContent(myPersonId: Int) -> Bool
}
