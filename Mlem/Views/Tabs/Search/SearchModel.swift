//
//  SearchModel.swift
//  Mlem
//
//  Created by Sjmarf on 26/08/2023.
//

import SwiftUI
import Dependencies

enum SearchSection {
    case communities
    case users
    case posts
    case comments
}

private actor SearchActor {
    var communities: [APICommunityView] = .init()
    var users: [APIPersonView] = .init()
    var posts: [APIPostView] = .init()
    var communityFilters: [SearchFilter] = .init()
    var userFilters: [SearchFilter] = .init()
    
    func setCommunities(_ communities: [APICommunityView]) async {
        self.communities = communities
    }
    
    func setCommunityFilters(_ filters: [SearchFilter]) async {
        self.communityFilters = filters
    }
    
    func setUserFilters(_ filters: [SearchFilter]) async {
        self.userFilters = filters
    }
    
    func setUsers(_ users: [APIPersonView]) async {
        self.users = users
    }
    
    func setPosts(_ posts: [APIPostView]) async {
        self.posts = posts
    }
}

class SearchModel: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    
    @Published var input: String = ""
    @Published var taskID: Int = 0
    @Published private(set) var sections: [SearchSection] = [.communities, .users, .posts, .comments]
    
    @Published var focused: Bool = false
    
    // Results
    @Published var communities = [APICommunityView]()
    @Published var users = [APIPersonView]()
    @Published var posts = [APIPostView]()
    
    // Filters
    @Published var activeFilters = [SearchFilter]()
    @Published var suggestedFilters = [SearchFilter?]()
    @Published private var originalSuggestedFilters = [SearchFilter?]()
    
    // Flags
    var activeCommunityFilter: APICommunityView?
    var activeUserFilter: APIPersonView?
    var activeTypeFilter: SearchFilter?
    
    @Published var page: Int = 0
    @Published var loadedPage: Int = 0
    
    func fetchResults() async throws {
        let sanitisedInput = input.lowercased().trimmingCharacters(in: .whitespaces)
        
        await MainActor.run {
            self.page = 0
            self.loadedPage = 0
            self.sections = getSections()
        }
        
        let actor = SearchActor()
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                if self.activeTypeFilter != .users && self.activeCommunityFilter == nil {
                    let communities = try await self.fetchCommunities(sanitisedInput)
                    await actor.setCommunities(communities)
                }
            }
            group.addTask {
                if self.activeTypeFilter != .communities && self.activeUserFilter == nil {
                    let users = try await self.fetchUsers(sanitisedInput)
                    await actor.setUsers(users)
                }
            }
            if [nil, .posts].contains(self.activeTypeFilter) {
                group.addTask {
                    if !sanitisedInput.isEmpty || self.activeCommunityFilter != nil || self.activeUserFilter != nil {
                        await actor.setPosts(try await self.fetchPosts(sanitisedInput))
                    }
                }
            }
            
            try await group.waitForAll()
            let communities = await actor.communities
            let users = await actor.users
            let posts = await actor.posts
    
            await MainActor.run {
                self.page = 1
                self.loadedPage = 1
                self.communities = communities
                self.users = users
                self.posts = posts
            }
        }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            if !(input.isEmpty && activeFilters.isEmpty) {
                if self.activeTypeFilter != .communities {
                    group.addTask {
                        try await actor.setCommunityFilters(self.generateCommunityFilters(self.communities, input: sanitisedInput))
                    }
                }
                if self.activeTypeFilter != .users {
                    group.addTask {
                        let filters: [SearchFilter]
                        if let firstUser = self.users.first(where: {$0.person.name.lowercased().hasPrefix(sanitisedInput) }) {
                            filters = [.user(firstUser)]
                        } else {
                            filters = .init()
                        }
                        await actor.setUserFilters(filters)
                    }
                }
            }
            
            try await group.waitForAll()
            
            let communityFilters = await actor.communityFilters
            let userFilters = await actor.userFilters
            
            
            await MainActor.run {
                var filters: [SearchFilter?] = communityFilters
                if !userFilters.isEmpty {
                    if !filters.isEmpty {
                        filters.append(nil)
                    }
                    filters.append(contentsOf: userFilters)
                }
                self.originalSuggestedFilters = filters
                self.suggestedFilters = self.getSuggestedFilters()
            }
        }
    }
    
    func getSections() -> [SearchSection] {
        activeCommunityFilter = nil
        activeUserFilter = nil
        activeTypeFilter = nil
        
        if input.isEmpty && activeFilters.isEmpty {
            activeTypeFilter = .communities
            return [.communities]
        }
        
        var returnVal: [SearchSection]? = nil
        
        for filter in activeFilters {
            switch filter {
            case .community(let community):
                activeCommunityFilter = community
            case .user(let user):
                activeUserFilter = user
            case .communities:
                activeTypeFilter = .communities
                returnVal = [.communities]
            case .users:
                activeTypeFilter = .users
                returnVal = [.users]
            case .posts:
                activeTypeFilter = .posts
                returnVal = [.posts]
            default:
                break
            }
        }
        
        if let val = returnVal {
            return val
        }
        
        if activeUserFilter != nil {
            if activeCommunityFilter != nil {
                return [.posts, .comments]
            } else {
                return [.posts, .comments, .communities]
            }
        } else if activeCommunityFilter != nil {
            return [.posts, .comments, .users]
        } else {
            return [.communities, .users, .posts, .comments]
        }
    }
    
    func getSuggestedFilters() -> [SearchFilter?] {
        self.originalSuggestedFilters.filter { filter in
            switch filter {
            case .community:
                return self.activeCommunityFilter == nil
            case .user:
                return self.activeUserFilter == nil
            default:
                return true
            }
        }
    }
    
    func addFilter(_ filter: SearchFilter) {
        activeFilters.append(filter)
        self.taskID += 1
    }
    
    func removeFilter(_ filter: SearchFilter) {
        if let index = activeFilters.firstIndex(of: filter) {
            activeFilters.remove(at: index)
            self.taskID += 1
        }
    }
    
    func clearFilters() {
        activeFilters.removeAll()
        self.taskID += 1
    }
    
    func loadMore() async throws {
        let sanitisedInput = input.lowercased().trimmingCharacters(in: .whitespaces)
        switch activeTypeFilter {
        case .users:
            let users = try await self.fetchUsers(sanitisedInput, page: self.page)
                .filter { !self.users.contains($0) }
            await MainActor.run {
                self.users.append(contentsOf: users)
            }
        case .posts:
            let posts = try await self.fetchPosts(sanitisedInput, page: self.page)
                .filter { !self.posts.contains($0) }
            await MainActor.run {
                self.posts.append(contentsOf: posts)
            }
        case .communities:
            let communities = try await self.fetchCommunities(sanitisedInput, page: self.page)
                .filter { !self.communities.contains($0) }
            await MainActor.run {
                self.communities.append(contentsOf: communities)
            }
        default:
            break
        }
        await MainActor.run {
            self.loadedPage = self.page
        }
    }
    
    private func fetchCommunities(_ input: String, page: Int = 1) async throws -> [APICommunityView] {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .communities,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: self.sections == [.communities] ? 50 : 5
        )
        return response.communities
    }
    
    private func generateCommunityFilters(_ communities: [APICommunityView], input: String) async throws -> [SearchFilter] {
        var filters = [SearchFilter]()
        var subscriberLimit: Int?
        
        for community in communities where community.community.name.lowercased().hasPrefix(input) {
            if let firstFilter = filters.first, case .community(let first) = firstFilter {
                if first.community.name == community.community.name && community.counts.subscribers > subscriberLimit! {
                    filters.append(.community(community))
                }
            } else {
                filters.append(.community(community))
                subscriberLimit = Int(Float(community.counts.subscribers) * 0.1)
            }
        }
        return filters
    }
        
    private func fetchUsers(_ input: String, page: Int = 1) async throws -> [APIPersonView] {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .users,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: self.sections == [.users] ? 50 : 3
        )
        return response.users
    }
    
    private func fetchPosts(_ input: String, page: Int = 1) async throws -> [APIPostView] {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .posts,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: self.sections == [.posts] ? 50 : 5,
            community: activeCommunityFilter?.community ?? nil,
            user: activeUserFilter?.person ?? nil
        )
        return response.posts
    }
}
