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
            BubblePicker(SearchTab.allCases, selected: $searchModel.searchTab) {
                Text($0.label)
            }
            .padding(.top, -2.5)
            .padding(.bottom, AppConstants.halfSpacing)
            Divider()
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
}

#Preview {
    SearchResultsViewPreview()
}

struct SearchResultsViewPreview: View {
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    @StateObject var searchModel: SearchModel = .init()
    @StateObject var contentTracker: ContentTracker<AnyContentModel> = .init()
    
    var body: some View {
        SearchResultsView(shouldLoad: true)
            .environmentObject(recentSearchesTracker)
            .environmentObject(searchModel)
            .environmentObject(contentTracker)
    }
}
