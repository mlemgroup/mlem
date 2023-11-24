//
//  SearchRoot.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import SwiftUI

struct SearchRoot: View {
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @StateObject private var searchRouter: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    var body: some View {
        NavigationStack(path: $searchRouter.path) {
            SearchView()
                .environmentObject(searchRouter)
                .tabBarNavigationEnabled(.search, navigation)
        }
        .environment(\.navigationPathWithRoutes, $searchRouter.path)
        .environmentObject(navigation)
        .handleLemmyLinkResolution(navigationPath: .constant(searchRouter))
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.search.hashValue {
                print("switched to Search tab")
            }
        }
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.search.hashValue {
                print("re-selected \(TabSelection.search) tab")
            }
        }
    }
}

#Preview {
    SearchRootPreview()
}

struct SearchRootPreview: View {
    
    @StateObject var appState: AppState = .init()
    @StateObject private var recentSearchesTracker: RecentSearchesTracker = .init()
    
    var body: some View {
        SearchRoot()
            .environmentObject(appState)
            .environmentObject(recentSearchesTracker)
    }
}
