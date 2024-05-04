//
//  NavigationLayerView.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

struct NavigationLayerView: View {
    @State var layer: NavigationLayer
    
    var body: some View {
        if layer.hasNavigationStack {
            NavigationStack(path: Binding(
                get: { layer.path },
                set: { layer.path = $0 }
            )) {
                layer.root.viewWithModifiers(layer: layer)
            }
            .environment(layer)
        } else {
            layer.root.viewWithModifiers(layer: layer)
                .environment(layer)
        }
    }
}
