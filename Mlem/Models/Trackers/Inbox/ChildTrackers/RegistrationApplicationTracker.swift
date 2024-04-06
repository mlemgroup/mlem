//
//  RegistrationApplicationTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Dependencies
import Foundation

class RegistrationApplicationTracker: ChildTracker<RegistrationApplicationModel, AnyInboxItem> {
    @Dependency(\.apiClient) var apiClient
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSort.Case, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    override func fetchPage(page: Int) async throws -> FetchResponse<RegistrationApplicationModel> {
        let newItems = try await apiClient.loadRegistrationApplications(
            page: page,
            limit: internetSpeed.pageSize,
            unresolvedOnly: unreadOnly
        )
        return .init(items: newItems, cursor: nil, numFiltered: 0)
    }
    
    override func toParent(item: RegistrationApplicationModel) -> AnyInboxItem {
        .registrationApplication(item)
    }
}
