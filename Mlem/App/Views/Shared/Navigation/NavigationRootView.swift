//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationSplitRootView: View {
    @State var layer: NavigationLayer
    let sidebar: NavigationPage
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all

    @State private var preferredColumn = NavigationSplitViewColumn.detail
    
    init(sidebar: NavigationPage, root: NavigationPage) {
        self._layer = .init(wrappedValue: .init(
            root: root,
            model: .main
        ))
        self.sidebar = sidebar
        self._columnVisibility = .init(wrappedValue: Settings.get(\.navigation_sidebarVisibleByDefault) ? .all : .detailOnly)
    }
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredColumn,
            sidebar: {
                sidebar.view()
            },
            detail: {
                NavigationLayerView(layer: layer, hasSheetModifiers: false)
            }
        )
        .modifier(HandleThreadiverseLinksModifier())
        .environment(layer)
        .onChange(of: layer.root.updateCountHash) {
            preferredColumn = .detail
        }
    }
}
