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
    
    @discardableResult
    func updateRead(_ newValue: Bool) -> Task<StateUpdateResult, Never>
}

public extension InboxItemProviding {
    @discardableResult
    func toggleRead() -> Task<StateUpdateResult, Never> {
        updateRead(!read)
    }
}
