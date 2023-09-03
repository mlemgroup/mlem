//
//  Replies Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Dependencies
import Foundation
import SwiftUI

class RepliesTracker: InboxTracker {
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("shouldFilterRead") var unreadOnly = false
    
    @Dependency(\.apiClient) var apiClient
    
    var isLoading: Bool = false
    
    var items: [APICommentReplyView] = []
    
    var ids: Set<APICommentReplyView.UniqueIdentifier> = .init(minimumCapacity: 1000)
    
    var page: Int = 0
    
    var shouldPerformMergeSorting: Bool = true
    
    func retrieveItems(for page: Int) async throws -> [APICommentReplyView] {
        try await apiClient.getReplies(sort: .new, page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly)
    }
}
