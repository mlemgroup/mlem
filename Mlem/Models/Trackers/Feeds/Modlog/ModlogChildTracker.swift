//
//  ModlogChildTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Dependencies
import Foundation

/// Class to handle modlog children. Because the API paginates the modlog per-action type, modlog needs to be handled using a multi-tracker; however, because all modlog entries are represented with ModlogEntry, we can define a single generic child tracker instead of needing 14 different ones
class ModlogChildTracker: ChildTracker<ModlogEntry, ModlogEntry> {
    @Dependency(\.apiClient) var apiClient
    
    private let actionType: ModlogAction
    private let instanceUrl: URL?
    private let communityId: Int?
    
    init(
        internetSpeed: InternetSpeed,
        sortType: TrackerSortType,
        actionType: ModlogAction,
        instance: URL?,
        communityId: Int?
    ) {
        self.actionType = actionType
        self.instanceUrl = instance
        self.communityId = communityId
        
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    override func toParent(item: ModlogEntry) -> ModlogEntry {
        item
    }
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, actionType: ModlogAction, modlogLink: ModlogLink) {
        self.actionType = actionType
        switch modlogLink {
        case .userInstance:
            self.instanceUrl = nil
            self.communityId = nil
        case let .instance(instance):
            self.instanceUrl = instance.url
            self.communityId = nil
        case let .community(community):
            self.instanceUrl = nil
            self.communityId = community.communityId
        }
        
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    override func fetchPage(page: Int) async throws -> FetchResponse<ModlogEntry> {
        // if first page, attempt to fetch from parent tracker
        if page == 1, let parentTracker = parentTracker as? ModlogTracker {
            if let items = try await parentTracker.getPreloadedItems(for: actionType, instanceUrl: instanceUrl, communityId: communityId) {
                return .init(items: items, cursor: nil, numFiltered: 0)
            } else {
                assertionFailure("Got no items from parent tracker!")
            }
        }
        
        // otherwise (or fallback in prod) get from API
        let items = try await apiClient.getModlog(
            for: instanceUrl,
            communityId: communityId,
            page: page,
            limit: internetSpeed.pageSize,
            type: actionType.toApiType
        )
        
        return .init(items: items, cursor: nil, numFiltered: 0)
    }
}
