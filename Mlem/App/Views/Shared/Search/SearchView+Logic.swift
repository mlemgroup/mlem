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
        if selectedTab == .posts {
            selectedTab = .communities
        }
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
            case .posts:
                try await refreshPosts(clearBeforeRefresh: clearBeforeRefresh)
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
    
    private func refreshPosts(clearBeforeRefresh: Bool) async throws {
        guard !query.isEmpty else { return }
        postLoader.api = getRefreshApi(for: postFilters.location)
        postLoader.query = query
        postLoader.sortType = postFilters.sort
        postLoader.creatorId = postFilters.creator?.id
        postLoader.communityId = nil
        postLoader.listing = .all
        switch postFilters.location {
        case .subscribed:
            postLoader.listing = .subscribed
        case .moderated:
            postLoader.listing = .moderatorView
        case .localInstance, .instance:
            postLoader.listing = .local
        case let .community(community):
            postLoader.communityId = community.id
        default:
            break
        }
        try await postLoader.refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
    
    private func getRefreshApi(for filter: InstanceFilter) -> ApiClient {
        if !filtersActive {
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
    
    private func getRefreshApi(for filter: LocationFilter) -> ApiClient {
        if !filtersActive {
            appState.firstApi
        } else {
            switch filter {
            case let .instance(instance):
                instance.instanceStub?.asLocal().api ?? appState.firstApi
            default:
                appState.firstApi
            }
        }
    }
    
    func resolvePostFilterCreator() {
        let api = postFilters.location.instanceStub?.api ?? appState.firstApi
        if let creator = postFilters.creator, api !== creator.api {
            Task {
                let stub = PersonStub(api: api, actorId: creator.actorId)
                do {
                    if let person = try await (stub.upgrade()) as? Person2 {
                        postFilters.creator = person
                    }
                } catch {
                    handleError(error)
                }
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
        hasher.combine(postFilters.sort)
        hasher.combine(postFilters.creator?.actorId)
        hasher.combine(postFilters.location)
        return hasher.finalize()
    }
}
