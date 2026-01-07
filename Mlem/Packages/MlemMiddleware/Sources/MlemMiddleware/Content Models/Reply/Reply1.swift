//
//  Reply1.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation
import Observation

@Observable
public final class Reply1: Reply1Providing {
    public static let tierNumber: Int = 1
    public var api: ApiClient
    public var reply1: Reply1 { self }
    
    public let id: Int
    public let recipientId: Int
    public let commentId: Int
    public let created: Date
    public let isMention: Bool
    
    public var purged: Bool = false
    
    let readManager: StateManager<Bool>
    public var read: Bool { readManager.displayedValue }
    
    init(
        api: ApiClient,
        id: Int,
        recipientId: Int,
        commentId: Int,
        created: Date,
        read: Bool,
        isMention: Bool
    ) {
        self.api = api
        self.id = id
        self.recipientId = recipientId
        self.commentId = commentId
        self.created = created
        self.isMention = isMention
        self.readManager = .init(wrappedValue: read)
        readManager.onSet = { newValue, type, _ in
            if type == .begin || type == .rollback {
                api.unreadCount?.updateUnverifiedItem(
                    itemType: isMention ? .mention : .reply,
                    isRead: newValue
                )
            }
        }
        readManager.onVerify = { newValue, _ in
            api.unreadCount?.verifyItem(
                itemType: isMention ? .mention : .reply,
                isRead: newValue
            )
        }
    }
}
