//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-01.
//

import Foundation

@Observable
public final class InboxNotification: ContentModel, Identifiable {
    public var updateQueue: InboxNotificationUpdateQueue = .init()
    
    public static var tierNumber: Int = 1
    public var api: ApiClient

    public let id: Int
    // This can be removed when we drop support for < Lemmy 1.0
    public let contentId: Int
    
    public var read: Bool
    public let content: InboxNotificationContent

    init(
        api: ApiClient,
        id: Int,
        contentId: Int,
        read: Bool,
        content: InboxNotificationContent
    ) {
        self.api = api
        self.id = id
        self.contentId = contentId
        self.read = read
        self.content = content
        
        Task {
            await updateQueue.setParent(self)
        }
    }
    
    public func updateRead(_ newValue: Bool) {
        read = newValue
        Task {
            await updateQueue.addItem {
                try await self.api.repository.markNotificationAsRead(
                    type: self.content.type,
                    id: self.id,
                    contentId: self.contentId,
                    read: newValue
                )
                var snapshot = self.takeSnapshot()
                snapshot.read = newValue
                return snapshot
            }
        }
    }
    
    public func toggleRead() {
        updateRead(!read)
    }

    public static func == (lhs: InboxNotification, rhs: InboxNotification) -> Bool {
        lhs.id == rhs.id
    }
}

extension InboxNotification: FeedLoadable {
    public typealias FilterType = InboxItemFilterType

    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            switch self.content {
            case let .mention(comment), let .reply(comment):
                return .new(comment.created)
            case let .message(message):
                return .new(message.created)
            }
        }
    }
}
