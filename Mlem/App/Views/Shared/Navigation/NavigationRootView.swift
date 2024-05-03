//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationRootView: View {
    @State var navigationModel: NavigationModel
    
    var body: some View {
        NavigationLayerView(layer: navigationModel.rootLayer)
    }
}

extension NavigationRootView {
    init(root: NavigationPage) {
        self._navigationModel = .init(wrappedValue: .init(root: root))
    }
}

struct NavigationSplitRootView<Content: View>: View {
    @State var navigationModel: NavigationModel
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    
    @ViewBuilder var sidebar: () -> Content
    
    init(root: NavigationPage, @ViewBuilder sidebar: @escaping () -> Content) {
        self._navigationModel = .init(wrappedValue: .init(root: root))
        self.sidebar = sidebar
    }
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: sidebar,
            detail: {
                NavigationStack(path: Binding(
                    get: { navigationModel.rootLayer.path },
                    set: {
                        navigationModel.rootLayer.path = $0
                    }
                )) {
                    navigationModel.rootLayer.root.viewWithModifiers(layer: navigationModel.rootLayer)
                        .navigationDestination(for: NavigationPage.self) { $0.view() }
                }
            }
        )
        .environment(navigationModel.rootLayer)
    }
}
