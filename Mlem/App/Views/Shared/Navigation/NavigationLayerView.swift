//
//  NavigationLayerView.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI
import SwiftUIIntrospect
import UIKit

struct NavigationLayerView: View {
    @Setting(\.appearance_interfaceStyle) var interfaceStyle

    @State var layer: NavigationLayer

    let hasSheetModifiers: Bool
    var selectedDetent: Binding<PresentationDetent>?
    
    var body: some View {
        Group {
            if layer.hasNavigationStack {
                NavigationStack(path: $layer.path) {
                    rootView()
                        .id(layer.root.updateCountHash)
                        .environment(\.isRootView, true)
                        .navigationDestination(for: NavigationFrame.self) {
                            NavigationFrameView(frame: $0)
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
            .ignoresSafeArea(edges: layer.isFullScreenCover ? [] : .top)
        }
        .overlay(alignment: .bottom) {
            ToastOverlayView(
                shouldDisplayNewToasts: layer.isToastDisplayer && hasSheetModifiers,
                location: .bottom
            )
            .padding(.bottom, 8)
        }
        .modifier(HandleThreadiverseLinksModifier())
        .environment(layer)
        .preferredColorScheme(preferredColorScheme)
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        if hasSheetModifiers {
            innerRootView().navigationSheetModifiers(for: layer)
        } else {
            innerRootView()
        }
    }

    @ViewBuilder
    private func innerRootView() -> some View {
        if let selectedDetent {
            layer.root.page.sheetView(selectedDetent: selectedDetent)
        } else {
            layer.root.page.view()
        }
    }
    
    private var preferredColorScheme: ColorScheme? {
        @Setting(\.appearance_palette) var colorPalette
        let newStyle: UIUserInterfaceStyle = colorPalette.supportedModes != .unspecified ? colorPalette.supportedModes : interfaceStyle
        
        // The image viewer relies on having a concrete color scheme for the status bar color.
        // Otherwise the status bar will "flash" when the sheet is dismissed
        if layer.isImageViewer, newStyle == .unspecified {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        }
        
        return newStyle.colorScheme
    }
}
