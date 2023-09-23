//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Dependencies
import Combine
import Foundation
import UIKit
import SwiftUI

struct SearchView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    // environment
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject private var recentSearchesTracker: RecentSearchesTracker
    @EnvironmentObject private var searchModel: SearchModel
    @EnvironmentObject private var contentTracker: ContentTracker<AnyContentModel>
    
    @State var shouldLoad: Bool = false
    
    var body: some View {
        content
            .handleLemmyViews()
            .navigationBarColor()
            .navigationTitle("Search")
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isSearching {
                    VStack {
                        if searchModel.searchText.isEmpty {
                            recentSearches
                            .transition(.opacity)
                        } else {
                            VStack(spacing: 0) {
                                tabs
                                Divider()
                                    .padding(.top, 8)
                                searchResults
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.default, value: searchModel.searchText.isEmpty)
                } else {
                    VStack(alignment: .leading) {
                        Text("Not searching")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .fancyTabScrollCompatible()
        .environmentObject(contentTracker)
        .onChange(of: shouldLoad) { value in
            if value {
                print("Loading page \(contentTracker.page + 1)...")
                Task(priority: .medium) { try await contentTracker.loadNextPage() }
            }
            shouldLoad = false
        }
    }
    
    @ViewBuilder
    private var recentSearches: some View {
        Group {
            if !recentSearchesTracker.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Recently Searched")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        
                        Button {
                            Task {
                                recentSearchesTracker.clearRecentSearches()
                            }
                        } label: {
                            Text("Clear")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 6)
                    Divider()
                    contentList(recentSearchesTracker.recentSearches)
                }
                .transition(.opacity)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .fontWeight(.thin)
                    Text("Search for communities and users.")
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
                .padding(100)
                .transition(.opacity)
            }
        }
        .animation(.default, value: recentSearchesTracker.recentSearches.isEmpty)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var tabs: some View {
        HStack {
            ScrollView(.horizontal) {
                SearchTabPicker(selected: $searchModel.searchTab)
                    .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            Group {
                if contentTracker.isLoading && contentTracker.page == 1 && !shouldLoad {
                    ProgressView()
                        .padding(.trailing)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: contentTracker.isLoading)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var searchResults: some View {
        Group {
            LazyVStack(spacing: 0) {
                contentList(contentTracker.items)
                VStack {
                    if contentTracker.isLoading && contentTracker.page > 1 {
                        ProgressView()
                    } else if contentTracker.items.isEmpty {
                        Text("No results found.")
                            .foregroundStyle(.secondary)
                    } else if contentTracker.hasReachedEnd && contentTracker.items.count > 10 {
                        HStack {
                            Image(systemName: "figure.climbing")
                            Text("I think I've found the bottom!")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .frame(height: 100)
            }
        }
    }
    
    @ViewBuilder
    func contentList(_ items: [AnyContentModel]) -> some View {
        ForEach(items, id: \.uid) { contentModel in
            Group {
                if let community = contentModel.wrappedValue as? CommunityModel {
                    CommunityResultView(community: community, showTypeLabel: searchModel.searchTab == .topResults)
                } else if let user = contentModel.wrappedValue as? UserModel {
                    UserResultView(user: user, showTypeLabel: searchModel.searchTab == .topResults)
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                recentSearchesTracker.addRecentSearch(contentModel)
            })
            Divider()
                .onAppear {
                    if contentTracker.shouldLoadContentAfter(after: contentModel) {
                        shouldLoad = true
                    }
                }
        }
    }
}
