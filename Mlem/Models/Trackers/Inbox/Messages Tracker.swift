//
//  Messages Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Dependencies
import Foundation
import SwiftUI

class MessagesTracker: InboxTracker {
    @Dependency(\.apiClient) var apiClient
    
    var items: [APIPrivateMessageView] = []
    
    var ids: Set<APIPrivateMessageView.UniqueIdentifier> = .init(minimumCapacity: 1000)
    
    var isLoading: Bool = false
    
    var page: Int = 0
    
    var shouldPerformMergeSorting: Bool = true
    
    var internetSpeed: InternetSpeed
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, unreadOnly: Bool) {
        self.internetSpeed = internetSpeed
        self.unreadOnly = unreadOnly
    }
    
    func retrieveItems(for page: Int) async throws -> [APIPrivateMessageView] {
        try await apiClient.getPrivateMessages(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly)
    }
}
