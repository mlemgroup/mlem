//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationSplitRootView<Content: View>: View {
    @State var layer: NavigationLayer
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    
    @ViewBuilder var sidebar: () -> Content
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                sidebar()
//                    .navigationDestination(for: NavigationPage.self) { root in
//                        layer.popToRoot()
//                        layer.root = root
//                        return NavigationLayerView(layer: layer, hasSheetModifiers: false)
//                    }
            },
            detail: {
                NavigationLayerView(layer: layer, hasSheetModifiers: false)
            }
        )
        .environment(layer)
    }
}
