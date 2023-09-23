//
//  MessageModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Foundation

/**
 Internal model to represent a private message.
 
 Note: To make the transition to internal models smoother, this is currently identical to APIPrivateMessageView
 */
struct MessageModel {
    let creator: APIPerson
    let recipient: APIPerson
    let privateMessage: APIPrivateMessage
    
    var uid: ContentModelIdentifier { .init(contentType: .message, contentId: privateMessage.id) }
    
    /// Creates a PrivateMessageModel from the raw APIPrivateMessageView returned by the Lemmy API
    /// - Parameter from: APIPrivateMessageView returned by the Lemmy API
    init(from apiPrivateMessageView: APIPrivateMessageView) {
        self.creator = apiPrivateMessageView.creator
        self.recipient = apiPrivateMessageView.recipient
        self.privateMessage = apiPrivateMessageView.privateMessage
    }
    
    func getInboxSortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            return .published(privateMessage.published)
        }
    }
}
