//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Combine
import Dependencies
import Foundation
import SwiftUI
import UIKit

private struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct SearchView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    enum Page {
        case home, recents, results
    }
    
    // environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var recentSearchesTracker: RecentSearchesTracker
    @StateObject var searchModel: SearchModel
    
    @StateObject var homeSearchModel: SearchModel
    @StateObject var homeContentTracker: ContentTracker<AnyContentModel> = .init()
    
    @State var isSearching: Bool = false
    @State var page: Page = .home
    
    init() {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        _searchModel = StateObject(wrappedValue: .init(internetSpeed: internetSpeed))
        _homeSearchModel = StateObject(wrappedValue: .init(searchTab: .communities, internetSpeed: internetSpeed))
    }
    
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
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .onAppear {
                Task(priority: .background) {
                    do {
                        try await recentSearchesTracker.reloadRecentSearches(accountHash: appState.currentActiveAccount?.hashValue)
                    } catch {
                        print("Error while loading recent searches: \(error.localizedDescription)")
                        errorHandler.handle(error)
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
        .onChange(of: isSearching) { newValue in
            if newValue, searchModel.searchText.isEmpty {
                page = .recents
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
        .scrollDismissesKeyboard(.immediately)
    }
}
