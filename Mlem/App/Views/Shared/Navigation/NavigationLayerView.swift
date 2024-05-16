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
                        .navigationDestination(for: NavigationPage.self) { $0.view() }
                }
                .environment(layer)
            } else {
                rootView()
                    .environment(layer)
            }
        }
        .overlay(alignment: .top) {
            ToastOverlayView(layer: layer)
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

struct ToastOverlayView: View {
    let layer: NavigationLayer
    @State var activeToast: Toast?
    
    var body: some View {
        Group {
            if let activeToast {
                ToastView(toast: activeToast)
            }
        }
        .onChange(of: layer.toasts.first) { _, newValue in
            activeToast = newValue?.activeToast
        }
        .task(id: activeToast) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                layer.toasts.remove(at: 0)
            }
        }
    }
}

struct ToastView: View {
    let toast: Toast
    var body: some View {
        HStack {
            switch toast {
            case let .basic(title: title, subtitle: subtitle, systemImage: systemImage, color: color):
                Text(title)
            default:
                Text("???")
            }
        }
        .frame(height: 30)
        .padding(.horizontal)
        .background(
            Capsule()
                .fill(Palette.main.secondaryBackground)
        )
    }
}
