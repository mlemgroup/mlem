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

class SearchModel: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    
    @Published var input: String = ""
    @Published var taskID: Int = 0
    @Published private(set) var sections: [SearchSection] = [.communities, .users, .posts, .comments]
    
    // Results
    @Published private(set) var communities = [APICommunityView]()
    @Published private(set) var users = [APIPersonView]()
    @Published private(set) var posts = [APIPostView]()
    
    // Filters
    @Published var activeFilters = [SearchFilter]()
    @Published var suggestedFilters = [SearchFilter?]()
    @Published private var originalSuggestedFilters = [SearchFilter?]()
    
    // Flags
    var activeCommunityFilter: APICommunityView?
    var activeUserFilter: APIPersonView?
    
    func fetchResults() async throws {
        let sanitisedInput = input.lowercased().trimmingCharacters(in: .whitespaces)
        if sanitisedInput.isEmpty && activeFilters.isEmpty {
            return
        }
        
        let sections = getSections()
        var newFilters = [SearchFilter?]()
        
        for section in sections {
            switch section {
            case .communities:
                let communities: [APICommunityView]
                
                if activeCommunityFilter == nil && !sanitisedInput.isEmpty {
                    communities = try await fetchCommunities(sanitisedInput)
                    newFilters.append(contentsOf: try await generateCommunityFilters(communities, input: input))
                } else {
                    communities = .init()
                }
                
                DispatchQueue.main.async {
                    self.communities = communities
                }
            case .users:
                let users: [APIPersonView]
                
                if activeUserFilter == nil && !sanitisedInput.isEmpty {
                    users = try await fetchUsers(sanitisedInput)
                    if let firstUser = users.first {
                        if !newFilters.isEmpty {
                            newFilters.append(nil)
                        }
                        newFilters.append(.user(firstUser))
                    }
                    
                } else {
                    users = .init()
                }
                
                DispatchQueue.main.async {
                    self.users = users
                }
                
            case .posts:
                let posts: [APIPostView]
                if !sanitisedInput.isEmpty || activeCommunityFilter != nil || activeUserFilter != nil {
                    posts = try await fetchPosts(sanitisedInput)
                } else {
                    posts = .init()
                }
                
                DispatchQueue.main.async {
                    self.posts = posts
                }
            case .comments:
                break
            }
            
            // This avoids an error in Swift 6
            let newFilters_ = newFilters
            DispatchQueue.main.async {
                self.originalSuggestedFilters = newFilters_
                self.updateSuggestedFilters()
                self.sections = sections
            }
        }
    }
    
    func getSections() -> [SearchSection] {
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
    
    func updateFlags() {
        activeCommunityFilter = nil
        activeUserFilter = nil
        
        for filter in activeFilters {
            switch filter {
            case .community(let community):
                activeCommunityFilter = community
            case .user(let user):
                activeUserFilter = user
            case .subscribed:
                break
            }
        }
    }
    
    func updateSuggestedFilters() {
        self.suggestedFilters = originalSuggestedFilters.filter { filter in
            switch filter {
            case .community:
                return activeCommunityFilter == nil
            case .user:
                return activeUserFilter == nil
            default:
                return true
            }
        }
    }
    
    func addFilter(_ filter: SearchFilter) {
        input = ""
        self.suggestedFilters = .init()
        activeFilters.append(filter)
        self.updateFlags()
        self.taskID = 0
    }
    
    func removeFilter(_ filter: SearchFilter) {
        if let index = activeFilters.firstIndex(of: filter) {
            activeFilters.remove(at: index)
            self.updateFlags()
            self.taskID = 0
        }
    }
    
    func clearFilters() {
        activeFilters.removeAll()
        self.sections = getSections()
        self.activeUserFilter = nil
        self.activeCommunityFilter = nil
        updateSuggestedFilters()
    }
    
    private func fetchCommunities(_ input: String) async throws -> [APICommunityView] {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .communities,
            sortOption: .topAll,
            listingType: .all,
            page: 1,
            limit: 5
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
        
    private func fetchUsers(_ input: String) async throws -> [APIPersonView] {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .users,
            sortOption: .topAll,
            listingType: .all,
            page: 1,
            limit: 3
        )
        return response.users
    }
    
    private func fetchPosts(_ input: String) async throws -> [APIPostView] {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .posts,
            sortOption: .topAll,
            listingType: .all,
            page: 1,
            limit: 5,
            community: activeCommunityFilter?.community ?? nil,
            user: activeUserFilter?.person ?? nil
        )
        return response.posts
    }
}
