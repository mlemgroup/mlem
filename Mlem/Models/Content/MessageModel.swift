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
    
    /// Dummy initializer for convenience
    init() {
        self.creator = APIPerson(
            id: 0,
            name: "dummy",
            displayName: nil,
            avatar: nil,
            banned: false,
            published: Date(),
            updated: nil,
            actorId: URL(string: "www.lemmy.ml")!,
            bio: nil,
            local: false,
            banner: nil,
            deleted: false,
            sharedInboxUrl: nil,
            matrixUserId: nil,
            admin: nil,
            botAccount: false,
            banExpires: nil,
            instanceId: 0
        )
        self.recipient = APIPerson(
            id: 0,
            name: "dummy",
            displayName: nil,
            avatar: nil,
            banned: false,
            published: Date(),
            updated: nil,
            actorId: URL(string: "www.lemmy.ml")!,
            bio: nil,
            local: false,
            banner: nil,
            deleted: false,
            sharedInboxUrl: nil,
            matrixUserId: nil,
            admin: nil,
            botAccount: false,
            banExpires: nil,
            instanceId: 0
        )
        self.privateMessage = APIPrivateMessage(
            id: 0,
            content: "dummy",
            creatorId: 0,
            recipientId: 0,
            local: false,
            read: false,
            updated: nil,
            published: Date(),
            deleted: false
        )
    }

    func getInboxSortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            return .published(privateMessage.published)
        }
    }
}

extension MessageModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(privateMessage.read)
        hasher.combine(privateMessage.updated)
    }
}

extension MessageModel: Identifiable {
    var id: Int { hashValue }
}

extension MessageModel: Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        lhs.id == rhs.id
    }
}
