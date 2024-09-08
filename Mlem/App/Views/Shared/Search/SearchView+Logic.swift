//
//  SearchView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 08/09/2024.
//

import Foundation

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
                try await communityLoader.refresh(
                    query: query,
                    sort: filtersActive ? communityFilters.sort : .topAll,
                    clearBeforeRefresh: clearBeforeRefresh
                )
            case .users:
                if onlyRefreshIfEmpty, !personLoader.items.isEmpty { return }
                try await personLoader.refresh(query: query, clearBeforeRefresh: clearBeforeRefresh)
            case .instances:
                if onlyRefreshIfEmpty, !instances.isEmpty { return }
                try await setInstances(MlemStats.main.searchInstances(query: query))
            }
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    func setInstances(_ newValue: [InstanceSummary]) {
        instances = newValue
    }
    
    var filterRefreshHashValue: Int {
        var hasher = Hasher()
        hasher.combine(filtersActive)
        hasher.combine(communityFilters.sort)
        return hasher.finalize()
    }
}
