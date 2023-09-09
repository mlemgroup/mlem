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
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("shouldFilterRead") var unreadOnly = false
    
    @Dependency(\.apiClient) var apiClient
    
    var items: [APIPrivateMessageView] = []
    
    var ids: Set<APIPrivateMessageView.UniqueIdentifier> = .init(minimumCapacity: 1000)
    
    var isLoading: Bool = false
    
    var page: Int = 0
    
    var shouldPerformMergeSorting: Bool = true
    
    func retrieveItems(for page: Int) async throws -> [APIPrivateMessageView] {
        try await apiClient.getPrivateMessages(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly)
    }
}
