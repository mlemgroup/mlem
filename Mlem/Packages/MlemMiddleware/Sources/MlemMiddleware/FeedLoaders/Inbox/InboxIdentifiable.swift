//
//  InboxIdentifiable.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-02-01.
//

public protocol InboxIdentifiable: Equatable {
    /// Identifier suitable for uniquely distinguishing inbox items from each other
    var inboxId: Int { get }
}
