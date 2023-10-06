//
//  SearchResultsView.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import SwiftUI

struct SearchResultsView: View {
    
    @EnvironmentObject var recentSearchesTracker: RecentSearchesTracker
    @EnvironmentObject var searchModel: SearchModel
    @StateObject var contentTracker: ContentTracker<AnyContentModel> = .init()
    
    @State var shouldLoad: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            tabs
            Divider()
                .padding(.top, 8)
            SearchResultListView(showTypeLabel: searchModel.searchTab == .topResults)
        }
        .onReceive(
            searchModel.$searchText
                .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
        ) { newValue in
            if searchModel.previousSearchText != newValue {
                if !newValue.isEmpty {
                    contentTracker.refresh(using: searchModel.performSearch)
                }
            }
        }
        .onChange(of: searchModel.searchTab) { _ in
            searchModel.tabSwitchRefresh(contentTracker: contentTracker)
        }
        .environmentObject(contentTracker)
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
}
