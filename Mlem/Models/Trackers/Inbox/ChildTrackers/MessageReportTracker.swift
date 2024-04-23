//
//  MessageReportTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Dependencies
import Foundation

class MessageReportTracker: ChildTracker<MessageReportModel, AnyInboxItem> {
    @Dependency(\.apiClient) var apiClient
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSort.Case, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    override func fetchPage(page: Int) async throws -> FetchResponse<MessageReportModel> {
        let newItems = try await apiClient.loadMessageReports(page: page, limit: internetSpeed.pageSize, unresolvedOnly: unreadOnly)
        return .init(items: newItems, cursor: nil, numFiltered: 0)
    }
    
    override func toParent(item: MessageReportModel) -> AnyInboxItem {
        .messageReport(item)
    }
}
