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
    
    init(sidebar: NavigationPage, root: NavigationPage) {
        self._layer = .init(wrappedValue: .init(
            root: UIDevice.isPad ? root : sidebar,
            path: UIDevice.isPad ? [] : [root],
            model: .main
        ))
        self.sidebar = sidebar
        self._columnVisibility = .init(wrappedValue: Settings.main.sidebarVisibleByDefault ? .all : .detailOnly)
    }
    
    var body: some View {
        MultiplatformView(
            phone: {
                NavigationLayerView(layer: layer, hasSheetModifiers: false)
            },
            pad: {
                NavigationSplitView(
                    columnVisibility: $columnVisibility,
                    sidebar: {
                        sidebar.view()
                    },
                    detail: {
                        NavigationLayerView(layer: layer, hasSheetModifiers: false)
                            .id(layer.root)
                    }
                )
            }
        )
        .environment(layer)
    }
}
