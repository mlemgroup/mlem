//
//  PostReportTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Dependencies
import Foundation

class PostReportTracker: ChildTracker<PostReportModel, AnyInboxItem> {
    @Dependency(\.apiClient) var apiClient
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortVal.Case, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    override func fetchPage(page: Int) async throws -> FetchResponse<PostReportModel> {
        let newItems = try await apiClient.loadPostReports(
            page: page,
            limit: internetSpeed.pageSize,
            unresolvedOnly: unreadOnly,
            communityId: nil
        )
        return .init(items: newItems, cursor: nil, numFiltered: 0)
    }
    
    override func toParent(item: PostReportModel) -> AnyInboxItem {
        .postReport(item)
    }
}
