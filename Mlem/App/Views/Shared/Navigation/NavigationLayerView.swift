//
//  NavigationLayerView.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

struct NavigationLayerView: View {
    @State var layer: NavigationLayer
    let hasSheetModifiers: Bool
    
    var body: some View {
        if layer.hasNavigationStack {
            NavigationStack(path: Binding(
                get: { layer.path },
                set: { layer.path = $0 }
            )) {
                rootView()
                    .environment(\.isFirstPage, true)
                    .navigationDestination(for: NavigationPage.self) { $0.view().environment(\.isFirstPage, false) }
            }
            .environment(layer)
        } else {
            rootView()
                .environment(\.isFirstPage, true)
                .environment(layer)
        }
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        if hasSheetModifiers {
            layer.root.viewWithModifiers(layer: layer)
        } else {
            layer.root.view()
        }
    }
}
