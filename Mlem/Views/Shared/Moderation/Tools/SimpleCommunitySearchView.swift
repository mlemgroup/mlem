//
//  SimpleCommunitySearchView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import Dependencies
import Foundation
import SwiftUI

/// Simple search view for finding a community. Takes in an optional filter to apply to community results and a callback, which will be activated when a community is tapped with the selected community.
struct SimpleCommunitySearchView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.dismiss) var dismiss
    
    @State var searchText: String = ""
    @State var communities: [CommunityModel] = .init()
    
    @StateObject var searchModel: SearchModel = .init(searchTab: .communities)
    
    let defaultItems: [CommunityModel]
    let resultsFilter: (CommunityModel) -> Bool
    let callback: (CommunityModel) -> Void
    
    var displayedItems: [CommunityModel] { communities.isEmpty ? defaultItems : communities }
    
    init(
        defaultItems: [CommunityModel]? = nil,
        resultsFilter: @escaping (CommunityModel) -> Bool = { _ in true },
        callback: @escaping (CommunityModel) -> Void
    ) {
        if let defaultItems {
            self.defaultItems = defaultItems.filter(resultsFilter)
        } else {
            self.defaultItems = .init()
        }
        self.resultsFilter = resultsFilter
        self.callback = callback
    }
    
    var body: some View {
        NavigationStack { // needed for .navigationTitle, .searchable to work in nested sheet
            content
                .searchable(text: $searchModel.searchText) // TODO: 2.0 add isPresented: $isSearching (iOS 17 exclusive)
                .onReceive(
                    searchModel.$searchText
                        .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
                ) { newValue in
                    if searchModel.previousSearchText != newValue, !newValue.isEmpty {
                        Task {
                            do {
                                let results = try await searchModel.performSearch(page: 1)
                                communities = results
                                    .compactMap { $0.wrappedValue as? CommunityModel }
                                    .filter(resultsFilter)
                            } catch {
                                errorHandler.handle(error)
                            }
                        }
                    }
                }
                .navigationTitle("Search for Community")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(displayedItems, id: \.uid) { community in
                    CommunityListRow(community, complications: [.instance, .subscribers], navigationEnabled: false)
                        .onTapGesture {
                            callback(community)
                            dismiss()
                        }
                    Divider()
                }
            }
        }
    }
}
