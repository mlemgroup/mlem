//
//  SearchView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 08/09/2024.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    var availableTabs: [Tab] {
        var ret: [Tab] = [.communities, .people, .instances, .posts]
        if appState.firstApi.supportsOrNil(.commentSearch) ?? false {
            ret.append(.comments)
        }
        return ret
    }
    
    func contentChangeTriggerRefresh(onlyRefreshIfEmpty: Bool) {
        editingRecentSearches = false
        if selectedTab == .posts || selectedTab == .comments {
            if page != .results {
                searchBarFocused = true
            }
        } else {
            Task {
                await refresh(clearBeforeRefresh: false, onlyRefreshIfEmpty: onlyRefreshIfEmpty)
            }
        }
    }
    
    func onFilterRefreshHashValueChange() {
        Task {
            await refresh(clearBeforeRefresh: selectedTab == .posts || selectedTab == .comments)
        }
    }
    
    func returnToHome() {
        if selectedTab == .posts || selectedTab == .comments {
            selectedTab = .communities
        }
        page = .home
        if !query.isEmpty {
            query = ""
            Task { await refresh(clearBeforeRefresh: true) }
        }
        resultsScrollToTopTrigger.toggle()
    }
    
    func setupFilters() async {
        do {
            let software = try await appState.firstApi.software
            communityFilters = .init(software: software)
            personFilters = .init(software: software)
            postFilters = .init(software: software)
        } catch {
            handleError(error)
        }
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
        guard let communityFilters else { return }
        let refreshApi = getRefreshApi(for: communityFilters.instance)
        await communityLoader.changeApi(
            to: refreshApi,
            context: filtersTracker.filterContext,
            hostApi: refreshApi == appState.firstApi ? nil : appState.firstApi
        )
        
        let defaultSort: SearchSortType
        if try await refreshApi.supports(.searchSortType(.top(.allTime))) {
            defaultSort = .top(.allTime)
        } else {
            defaultSort = .top(.limited(.month))
        }
        
        try await communityLoader.refresh(
            query: query,
            listing: (!filtersActive || communityFilters.instance == .any) ? .all : .local,
            sort: filtersActive ? communityFilters.sort : defaultSort,
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func refreshPeople(clearBeforeRefresh: Bool) async throws {
        guard let personFilters else { return }
        let refreshApi = getRefreshApi(for: personFilters.instance)
        await personLoader.changeApi(
            to: refreshApi,
            context: filtersTracker.filterContext
        )
        
        let defaultSort: SearchSortType
        if try await refreshApi.supports(.searchSortType(.top(.allTime))) {
            defaultSort = .top(.allTime)
        } else {
            defaultSort = .top(.limited(.month))
        }
        
        try await personLoader.refresh(
            query: query,
            listing: (!filtersActive || personFilters.instance == .any) ? .all : .local,
            sort: filtersActive ? personFilters.sort : defaultSort,
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func refreshPosts(clearBeforeRefresh: Bool) async throws {
        guard let postFilters else { return }
        guard !query.isEmpty else { return }
        await postLoader.searchPostFetcher.changeApi(
            to: getRefreshApi(for: postFilters.location),
            context: filtersTracker.filterContext
        )
        postLoader.searchPostFetcher.setSortType(.v3(postFilters.sort))
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
        await commentLoader.searchCommentFetcher.changeApi(
            to: getRefreshApi(for: commentFilters.location)
        )
        var listing: ListingType = .all
        commentLoader.searchCommentFetcher.communityId = nil
        commentLoader.searchCommentFetcher.creatorId = commentFilters.creator?.id
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
            sort: .v3(commentFilters.sort),
            clearBeforeRefresh: clearBeforeRefresh
        )
    }
    
    private func getRefreshApi(for filter: InstanceFilter) -> ApiClient {
        if !filtersActive {
            appState.firstApi
        } else {
            switch filter {
            case let .other(instance):
                instance.instanceStub.asLocal().api
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
                instance.instanceStub.asLocal().api
            default:
                appState.firstApi
            }
        }
    }
    
    func resolvePostFilterCreator() {
        guard let postFilters else { return }
        let api = postFilters.location.instanceStub?.api ?? appState.firstApi
        if let creator = postFilters.creator, api !== creator.api {
            Task {
                let stub = PersonStub(api: api, url: creator.actorId.url)
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
        hasher.combine(communityFilters?.instance.isOther)
        hasher.combine(selectedTab)
        return hasher.finalize()
    }
    
    var filterRefreshHashValue: Int {
        var hasher = Hasher()
        hasher.combine(filtersActive)
        hasher.combine(communityFilters?.sort)
        hasher.combine(communityFilters?.instance)
        hasher.combine(personFilters?.sort)
        hasher.combine(personFilters?.instance)
        hasher.combine(instanceFilters.sort)
        hasher.combine(postFilters?.sort)
        hasher.combine(postFilters?.creator?.actorId)
        hasher.combine(postFilters?.location)
        hasher.combine(commentFilters.sort)
        hasher.combine(commentFilters.creator?.actorId)
        hasher.combine(commentFilters.location)
        return hasher.finalize()
    }
}
