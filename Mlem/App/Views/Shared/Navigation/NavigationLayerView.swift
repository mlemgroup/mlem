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
        Group {
            if layer.hasNavigationStack {
                NavigationStack(path: Binding(
                    get: { layer.path },
                    set: { layer.path = $0 }
                )) {
                    rootView()
                        .environment(\.isRootView, true)
                        .navigationDestination(for: NavigationPage.self) {
                            $0.view()
                                .environment(\.isRootView, false)
                        }
                }
               
            } else {
                rootView()
                    .environment(\.isRootView, true)
            }
        }
        .overlay(alignment: .top) {
            ToastOverlayView(
                shouldDisplayNewToasts: layer.isToastDisplayer && hasSheetModifiers,
                location: .top
            )
            .padding(.top, 8)
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            ToastOverlayView(
                shouldDisplayNewToasts: layer.isToastDisplayer && hasSheetModifiers,
                location: .bottom
            )
            .padding(.bottom, 8)
        }
        .environment(layer)
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        if hasSheetModifiers {
            layer.root
                .viewWithModifiers(layer: layer)
        } else {
            layer.root.view()
        }
    }
}
