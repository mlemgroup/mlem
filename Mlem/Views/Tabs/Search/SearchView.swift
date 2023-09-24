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
import SwiftUIX

private struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct SearchView: View {
    
    enum Page {
        case home, recents, results
    }
    
    // environment
    @EnvironmentObject private var recentSearchesTracker: RecentSearchesTracker
    @StateObject var searchModel: SearchModel = .init()
    
    @StateObject var homeSearchModel: SearchModel = .init(searchTab: .communities)
    @StateObject var homeContentTracker: ContentTracker<AnyContentModel> = .init()
    
    @State var isSearching: Bool = false
    @State var page: Page = .home
    
    var body: some View {
        content
            .handleLemmyViews()
            .navigationBarColor()
            .navigationTitle("Search")
            .navigationSearchBar {
                SearchBar("Search for communities & users", text: $searchModel.searchText, isEditing: $isSearching)
                    .showsCancelButton(page != .home)
                    .onCancel {
                        page = .home
                        searchModel.searchText = ""
                    }
                    
                }
            .navigationSearchBarHiddenWhenScrolling(true)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .onAppear {
                Task(priority: .background) {
                    if !recentSearchesTracker.hasLoaded {
                        try await recentSearchesTracker.loadRecentSearches()
                    }
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack {
                switch page {
                case .home:
                    SearchHomeView()
                        .transition(.opacity)
                        .environmentObject(homeSearchModel)
                        .environmentObject(homeContentTracker)
                case .recents:
                    RecentSearchesView()
                        .transition(.opacity)
                case .results:
                    SearchResultsView()
                        .transition(.opacity)
                }
            }
            .animation(.default, value: page)
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: isSearching) { newValue in
            if newValue && searchModel.searchText.isEmpty {
                page =  .recents
            }
        }
        .onChange(of: searchModel.searchText) { newValue in
            if page != .home {
                if newValue.isEmpty {
                    page = .recents
                } else {
                    page = .results
                }
            }
        }
        .fancyTabScrollCompatible()
        .environmentObject(searchModel)
    }
}
