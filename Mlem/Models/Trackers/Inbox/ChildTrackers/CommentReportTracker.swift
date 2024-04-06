//
//  CommentReportTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Dependencies
import Foundation

class CommentReportTracker: ChildTracker<CommentReportModel, AnyInboxItem> {
    @Dependency(\.apiClient) var apiClient
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSort.Case, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    override func fetchPage(page: Int) async throws -> FetchResponse<CommentReportModel> {
        let newItems = try await apiClient.loadCommentReports(
            page: page,
            limit: internetSpeed.pageSize,
            unresolvedOnly: unreadOnly,
            communityId: nil
        )
        return .init(items: newItems, cursor: nil, numFiltered: 0)
    }
    
    override func toParent(item: CommentReportModel) -> AnyInboxItem {
        .commentReport(item)
    }
}
