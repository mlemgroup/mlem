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

    init(
        api: ApiClient,
        id: Int,
        read: Bool
    ) {
        self.api = api
        self.id = id
        self.read = read
    }
}
