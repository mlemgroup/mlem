//
//  SearchRoot.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import SwiftUI

struct SearchRoot: View {
    @StateObject private var searchRouter: AnyNavigationPath<AppRoute> = .init()
    
    var body: some View {
        NavigationStack(path: $searchRouter.path) {
            SearchView()
        }
        .handleLemmyLinkResolution(navigationPath: .constant(searchRouter))
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
