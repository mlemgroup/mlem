//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-01.
//

import Foundation

@Observable
public class InboxNotification: ContentModel, Identifiable {
    public static var tierNumber: Int = 1
    public var api: ApiClient

    public let id: Int
    public var read: Bool
    public let content: InboxNotificationContent

    init(
        api: ApiClient,
        id: Int,
        read: Bool,
        content: InboxNotificationContent
    ) {
        self.api = api
        self.id = id
        self.read = read
        self.content = content
    }
}

public enum InboxNotificationContent {
    case reply(Comment2)
    case mention(Comment2)
    case message(Message2)
}
