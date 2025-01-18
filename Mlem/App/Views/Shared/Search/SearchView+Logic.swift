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
    
    // swiftlint:disable:next cyclomatic_complexity
    func refresh(clearBeforeRefresh: Bool, onlyRefreshIfEmpty: Bool = false) async {
        do {
            if !query.isEmpty {
                try await Task.sleep(for: .seconds(0.2))
            }
            if clearBeforeRefresh {
                setInstances(.init())
            }
            switch selectedTab {
            case .communities:
                if onlyRefreshIfEmpty, !communityLoader.items.isEmpty { return }
                try await refreshCommunities(clearBeforeRefresh: clearBeforeRefresh)
            case .people:
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
            case .comments:
                try await refreshComments(clearBeforeRefresh: clearBeforeRefresh)
            }
        } catch {
            handleError(error)
        }
    }
    
    private func refreshCommunities(clearBeforeRefresh: Bool) async throws {
        await communityLoader.changeApi(
            to: getRefreshApi(for: communityFilters.instance),
            context: filtersTracker.filterContext
        )
        try await communityLoader.refresh(
            query: query,
            listing: (!filtersActive || communityFilters.instance == .any) ? .all : .local,
            sort: filtersActive ? communityFilters.sort : .topAll,
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func refreshPeople(clearBeforeRefresh: Bool) async throws {
        await personLoader.changeApi(
            to: getRefreshApi(for: personFilters.instance),
            context: filtersTracker.filterContext
        )
        try await personLoader.refresh(
            query: query,
            listing: (!filtersActive || personFilters.instance == .any) ? .all : .local,
            sort: filtersActive ? personFilters.sort : .topAll,
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func refreshPosts(clearBeforeRefresh: Bool) async throws {
        guard !query.isEmpty else { return }
        await postLoader.searchPostFetcher.changeApi(
            to: getRefreshApi(for: postFilters.location),
            context: filtersTracker.filterContext
        )
        postLoader.searchPostFetcher.setSortType(postFilters.sort)
        postLoader.searchPostFetcher.query = query
        postLoader.searchPostFetcher.creatorId = postFilters.creator?.id
        postLoader.searchPostFetcher.communityId = nil
        postLoader.searchPostFetcher.listing = .all
        switch postFilters.location {
        case .subscribed:
            postLoader.searchPostFetcher.listing = .subscribed
        case .moderated:
            postLoader.searchPostFetcher.listing = .moderatorView
        case .localInstance, .instance:
            postLoader.searchPostFetcher.listing = .local
        case let .community(community):
            postLoader.searchPostFetcher.communityId = community.id
        default:
            break
        }
        try await postLoader.refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
    
    public func refreshComments(clearBeforeRefresh: Bool) async throws {
        guard !query.isEmpty else { return }
        var listing: ApiListingType = .all
        switch commentFilters.location {
        case .subscribed:
            listing = .subscribed
        case .moderated:
            listing = .moderatorView
        case .localInstance, .instance:
            listing = .local
        case let .community(community):
            commentLoader.searchCommentFetcher.communityId = community.id
        default:
            break
        }
        try await commentLoader.refresh(
            query: query,
            listing: listing,
            sort: commentFilters.sort,
            clearBeforeRefresh: clearBeforeRefresh
        )
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
        hasher.combine(commentFilters.sort)
        hasher.combine(commentFilters.creator?.actorId)
        hasher.combine(commentFilters.location)
        return hasher.finalize()
    }
}
