//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationRoot: View {
    @State var navigationModel: NavigationModel
    
    init(root: NavigationPage) {
        self._navigationModel = .init(wrappedValue: .init(root: root))
    }
    
    var body: some View {
        NavigationLayerView(layer: navigationModel.root)
    }
}

struct NavigationLayerView: View {
    @State var layer: NavigationLayer
    
    var body: some View {
        if let path = layer.path {
            NavigationStack(path: Binding(
                get: { path }, set: { layer.path = $0 }
            )
            ) { content }
                .environment(layer)
        } else {
            content
                .environment(layer)
        }
    }
    
    @ViewBuilder
    var content: some View {
        layer.root.view()
            .navigationDestination(for: NavigationPage.self) { $0.view() }
            .sheet(isPresented: Binding(
                get: { (layer.model?.layers.count ?? 0) > (layer.index + 1) },
                set: { newValue in
                    if !newValue, let model = layer.model {
                        model.layers.removeLast(model.layers.count - layer.index - 1)
                    }
                }
            )) {
                if let model = layer.model {
                    NavigationLayerView(layer: model.layers[layer.index + 1])
                }
            }
    }
}
