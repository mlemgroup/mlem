//
//  Mentions Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Dependencies
import Foundation
import SwiftUI

class MentionsTracker: InboxTracker {
    @Dependency(\.apiClient) var apiClient
    
    @Published var items: [APIPersonMentionView] = []
    
    var ids: Set<APIPersonMentionView.UniqueIdentifier> = .init(minimumCapacity: 1000)
    
    var isLoading: Bool = false
    
    var page: Int = 0
    
    var shouldPerformMergeSorting: Bool = true
    
    var internetSpeed: InternetSpeed
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, unreadOnly: Bool) {
        self.internetSpeed = internetSpeed
        self.unreadOnly = unreadOnly
    }
    
    func retrieveItems(for page: Int) async throws -> [APIPersonMentionView] {
        try await apiClient.getPersonMentions(
            sort: .new,
            page: page,
            limit: internetSpeed.pageSize,
            unreadOnly: unreadOnly
        )
    }
}
