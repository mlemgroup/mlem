//
//  SearchRoot.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import SwiftUI

struct SearchRoot: View {
    @StateObject private var searchRouter: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $searchRouter.path) {
                SearchView()
                    .environmentObject(searchRouter)
                    .tabBarNavigationEnabled(.search, navigation)
            }
            .environment(\.scrollViewProxy, proxy)
            .environment(\.navigationPathWithRoutes, $searchRouter.path)
            .environmentObject(navigation)
            .handleLemmyLinkResolution(navigationPath: .constant(searchRouter))
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
