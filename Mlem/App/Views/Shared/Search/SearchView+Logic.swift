//
//  SearchView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 08/09/2024.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    func returnToHome() {
        page = .home
        if !query.isEmpty {
            query = ""
            Task { await refresh(clearBeforeRefresh: true) }
        }
        resultsScrollToTopTrigger.toggle()
    }
    
    func refresh(clearBeforeRefresh: Bool, onlyRefreshIfEmpty: Bool = false) async {
        do {
            if !query.isEmpty {
                try await Task.sleep(for: .seconds(0.2))
            }
            if clearBeforeRefresh {
                await setInstances(.init())
            }
            switch selectedTab {
            case .communities:
                if onlyRefreshIfEmpty, !communityLoader.items.isEmpty { return }
                try await refreshCommunities(clearBeforeRefresh: clearBeforeRefresh)
            case .users:
                if onlyRefreshIfEmpty, !personLoader.items.isEmpty { return }
                try await refreshPeople(clearBeforeRefresh: clearBeforeRefresh)
            case .instances:
                if onlyRefreshIfEmpty, !instances.isEmpty { return }
                try await setInstances(MlemStats.main.searchInstances(
                    query: query,
                    sort: filtersActive ? instanceFilters.sort : .score
                ))
            }
        } catch {
            handleError(error)
        }
    }
    
    private func refreshCommunities(clearBeforeRefresh: Bool) async throws {
        communityLoader.api = getRefreshApi(for: communityFilters.instance)
        try await communityLoader.refresh(
            query: query,
            listing: (!filtersActive || communityFilters.instance == .any) ? .all : .local,
            sort: filtersActive ? communityFilters.sort : .topAll,
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func refreshPeople(clearBeforeRefresh: Bool) async throws {
        personLoader.api = getRefreshApi(for: personFilters.instance)
        try await personLoader.refresh(
            query: query,
            listing: (!filtersActive || communityFilters.instance == .any) ? .all : .local,
            sort: filtersActive ? personFilters.sort : .topAll,
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func getRefreshApi(for filter: InstanceFilter) -> ApiClient {
        if filtersActive {
            appState.firstApi
        } else {
            switch filter {
            case let .other(instance):
                instance.instanceStub?.asLocal().api ?? appState.firstApi
            default:
                appState.firstApi
            }
        }
    }
    
    @MainActor
    func setInstances(_ newValue: [InstanceSummary]) {
        instances = newValue
    }
    
    var filterAnimationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(filtersActive)
        hasher.combine(communityFilters.instance.isOther)
        hasher.combine(selectedTab)
        return hasher.finalize()
    }
    
    var filterRefreshHashValue: Int {
        var hasher = Hasher()
        hasher.combine(filtersActive)
        hasher.combine(communityFilters.sort)
        hasher.combine(communityFilters.instance)
        hasher.combine(personFilters.sort)
        hasher.combine(personFilters.instance)
        hasher.combine(instanceFilters.sort)
        return hasher.finalize()
    }
}
