//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationRootView: View {
    @State var navigationModel: NavigationModel
    
    init(root: NavigationPage) {
        self._navigationModel = .init(wrappedValue: .init(root: root))
    }
    
    var body: some View {
        NavigationLayerView(layer: navigationModel.rootLayer)
    }
}

struct NavigationSplitRootView: View {
    @State var navigationModel: NavigationModel
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    
    init(root: NavigationPage) {
        self._navigationModel = .init(wrappedValue: .init(root: root))
    }
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                Button("Push") {
                    navigationModel.rootLayer.push(.page1)
                }
            },
            detail: {
                NavigationStack(path: Binding(
                    get: { navigationModel.rootLayer.path },
                    set: {
                        navigationModel.rootLayer.path = $0
                    }
                )) {
                    navigationModel.rootLayer.root.viewWithModifiers(layer: navigationModel.rootLayer)
                }
            }
        )
        .environment(navigationModel.rootLayer)
    }
}
