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

private struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct SearchView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    enum Page {
        case home, recents, results
    }
    
    // environment
    @Environment(\.scrollViewProxy) private var scrollProxy
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.tabSelectionHashValue) var tabSelectionHashValue
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var recentSearchesTracker: RecentSearchesTracker
    
    @StateObject var searchModel: SearchModel
    @StateObject var homeSearchModel: SearchModel
    
    @StateObject var homeContentTracker: ContentTracker<AnyContentModel> = .init()
    
    @State var searchBarFocused: Bool = false
    @State var isSearching: Bool = false
    @State var page: Page = .home
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @State private var recentsScrollToTopSignal: Int = .min
    @State private var resultsScrollToTopSignal: Int = .min
    
    @Namespace private var resultsScrollToTop
    @Namespace private var recentsScrollToTop
    
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
                        resultsScrollToTopSignal += 1
                        recentsScrollToTopSignal += 1
                    }
                    .focused($searchBarFocused)
            }
            .navigationSearchBarHiddenWhenScrolling(false)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .onAppear {
                if SearchModel.allInstances.isEmpty {
                    Task(priority: .background) {
                        var instances: [InstanceModel] = []
                        do {
                            instances = try await apiClient.fetchInstanceList().map { InstanceModel(from: $0) }
                            DispatchQueue.main.async {
                                SearchModel.allInstances = instances
                            }
                        } catch {
                            print("Error while loading instance stubs: \(error.localizedDescription)")
                            errorHandler.handle(error)
                        }
                        do {
                            try await recentSearchesTracker.reloadRecentSearches(
                                accountId: appState.currentActiveAccount?.stableIdString,
                                instances: instances
                            )
                        } catch {
                            print("Error while loading recent searches: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .onChange(of: searchModel.searchText) { value in
                if value.isEmpty {
                    resultsScrollToTopSignal += 1
                }
            }
            .onChange(of: tabSelectionHashValue) { newValue in
                // due to the hack in SearchBar:136, this is required to move focus off of the search bar when changing tabs
                // because the keyboard hides the tab bar and so users are required to cancel a search to switch tabs, this
                // probably isn't needed in most cases, but since it's possible to disable the on-screen keyboard I've included it
                if tabSelectionHashValue == TabSelection.search.hashValue, newValue != TabSelection.search.hashValue {
                    searchBarFocused = false
                }
            }
            .hoistNavigation {
                if scrollToTopAppeared {
                    searchBarFocused = true
                } else {
                    withAnimation {
                        scrollToTop(page: page)
                    }
                }
                return true
            }
    }
    
    @ViewBuilder
    private var content: some View {
        ZStack {
            ScrollView {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                
                SearchHomeView()
                    .environmentObject(homeSearchModel)
                    .environmentObject(homeContentTracker)
            }
            .fancyTabScrollCompatible()
            .scrollDismissesKeyboard(.immediately)
            ._opacity(page == .home ? 1 : 0, speed: page == .home ? 1 : 0)
            .zIndex(page == .home ? 1 : 0)
            
            ScrollView {
                HStack { EmptyView() }
                    .id(recentsScrollToTop)
                RecentSearchesView()
            }
            .fancyTabScrollCompatible()
            .scrollDismissesKeyboard(.immediately)
            ._opacity(page == .recents ? 1 : 0, speed: page == .recents ? 1 : 0)
            .zIndex(page == .recents ? 1 : 0)
            .onChange(of: recentsScrollToTopSignal) { _ in
                scrollProxy?.scrollTo(recentsScrollToTop)
            }
            
            ScrollView {
                HStack { EmptyView() }
                    .id(resultsScrollToTop)
                SearchResultsView()
                    .environmentObject(searchModel)
            }
            .fancyTabScrollCompatible()
            .scrollDismissesKeyboard(.immediately)
            ._opacity(page == .results ? 1 : 0, speed: page == .results ? 1 : 0)
            .zIndex(page == .results ? 1 : 0)
            .onChange(of: resultsScrollToTopSignal) { _ in
                scrollProxy?.scrollTo(resultsScrollToTop)
            }
        }
        .animation(.default, value: page)
        .transition(.opacity)
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
    }
    
    private func scrollToTop(page: Page) {
        switch page {
        case .home:
            scrollProxy?.scrollTo(scrollToTop, anchor: .bottom)
        case .recents:
            scrollProxy?.scrollTo(recentsScrollToTop, anchor: .bottom)
        case .results:
            scrollProxy?.scrollTo(resultsScrollToTop, anchor: .bottom)
        }
    }
}

extension View {
    @ViewBuilder
    func _opacity(_ opacity: Double, speed: Double) -> some View {
        if #available(iOS 17.0, *) {
            self.transaction { transaction in
                if speed > 0 {
                    transaction.animation = transaction.animation?.speed(speed)
                } else {
                    transaction.animation = nil
                }
            } body: { view in
                view.opacity(opacity)
            }
        } else {
            self.opacity(opacity)
                .transaction { transaction in
                    if speed > 0 {
                        transaction.animation = transaction.animation?.speed(speed)
                    } else {
                        transaction.animation = nil
                    }
                }
        }
    }
}

#Preview {
    SearchViewPreview()
}

struct SearchViewPreview: View {
    @StateObject private var appState: AppState = .init()
    @StateObject private var recentSearchesTracker: RecentSearchesTracker = .init()

    var body: some View {
        SearchView()
            .environmentObject(appState)
            .environmentObject(recentSearchesTracker)
    }
}
