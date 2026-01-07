//
//  InboxItemProviding.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public protocol InboxItemProviding: ContentIdentifiable, ContentModel, ReadableProviding {
    var created: Date { get }
    var read: Bool { get }
    var shimRead: Bool { get }
    
    @discardableResult
    func updateRead(_ newValue: Bool) -> Task<StateUpdateResult, Never>
}

public extension InboxItemProviding {
    var shimRead: Bool { read }
    
    @discardableResult
    func toggleRead() -> Task<StateUpdateResult, Never> {
        updateRead(!shimRead)
    }
}
