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
            sidebar: sidebar,
            detail: {
                NavigationStack(path: Binding(
                    get: { layer.path },
                    set: {
                        layer.path = $0
                    }
                )) {
                    layer.root.view()
                        .environment(\.isRootView, true)
                        .navigationDestination(for: NavigationPage.self) { $0.view() }
                }
            }
        )
        .environment(layer)
    }
}
