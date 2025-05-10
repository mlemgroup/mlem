//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-10.
//

import Foundation

public struct RegistrationApplicationSnapshot: CacheIdentifiable {
    // Won't change.
    public let id: Int
    public let created: Date
    
    // I don't *think* these can change, but I'm assuming they do
    // incase the ability to edit applications is added in future.
    // Update RegistrationApplication if you change these!
    public let questionResponse: String
    public let email: String?
    public let showNsfw: Bool

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of RegistrationApplication!
    public let emailVerified: Bool
}
