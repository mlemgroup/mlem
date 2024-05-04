//
//  NavigationPage+View.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

extension NavigationPage {
    @ViewBuilder
    func viewWithModifiers(layer: NavigationLayer) -> some View {
        view()
            .navigationDestination(for: NavigationPage.self) { $0.view() }
            .sheet(isPresented: Binding(
                get: { (layer.model?.layers.count ?? 0) > (layer.index + 1)
                    && !(layer.model?.layers[layer.index + 1].isFullScreenCover ?? true)
                },
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
            .fullScreenCover(isPresented: Binding(
                get: { (layer.model?.layers.count ?? 0) > (layer.index + 1)
                    && (layer.model?.layers[layer.index + 1].isFullScreenCover ?? false)
                },
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
