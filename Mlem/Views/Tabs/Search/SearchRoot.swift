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
    @StateObject private var searchRouter: NavigationRouter<NavigationRoute> = .init()
    
    var body: some View {
        NavigationStack(path: $searchRouter.path) {
            SearchView()
        }
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
