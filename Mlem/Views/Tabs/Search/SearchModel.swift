//
//  SearchModel.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import SwiftUI
import Dependencies

enum SearchTab: String, CaseIterable {
    case communities, users
    
    var label: String {
        return rawValue.capitalized
//        switch self {
//        case .topResults:
//            return "Top Results"
//        default:
//            return rawValue.capitalized
//        }
    }
}

class SearchModel: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    @Published var searchText: String = ""
    @Published var searchTab: SearchTab = .communities
    private var searchTask: Task<Void, Never>?
    
    @Published var communityViews: [APICommunityView] = .init()
    
    func performSearch() {
        // If we are searching, cancel the task
        if let task = searchTask {
            if !task.isCancelled {
                task.cancel()
                searchTask = nil
            }
        }
        
        searchTask = Task(priority: .userInitiated) { [searchText] in
            do {
                let response = try await apiClient.performSearch(
                    query: searchText,
                    searchType: .communities,
                    sortOption: .topAll,
                    listingType: .all,
                    page: 1,
                    limit: 10
                )
                
                DispatchQueue.main.async {
                    self.communityViews = response.communities
                }
                
            } catch is CancellationError {
                print("Search cancelled")
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
