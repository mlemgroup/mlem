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
    
    private let fullWidthGestureRecognizerDelegate: FullWidthGestureRecognizerDelegate = .init()
    
    var body: some View {
        Group {
            if layer.hasNavigationStack {
                NavigationStack(path: $layer.path) {
                    rootView()
                        .environment(\.isRootView, true)
                        .navigationDestination(for: NavigationPage.self) {
                            $0.view()
                                .environment(\.isRootView, false)
                        }
                }
                .introspect(.navigationStack, on: .iOS(.v17, .v18)) { controller in
                    // This is for the "Swipe anywhere to navigate" setting
                    // https://stackoverflow.com/questions/20714595/extend-default-interactivepopgesturerecognizer-beyond-screen-edge
                    guard
                        let interactivePopGestureRecognizer = controller.interactivePopGestureRecognizer,
                        let targets = interactivePopGestureRecognizer.value(forKey: "targets")
                    else {
                        return
                    }
                    
                    let fullWidthBackGestureRecognizer = UIPanGestureRecognizer()
                    fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
                    fullWidthGestureRecognizerDelegate.navigationController = controller
                    fullWidthBackGestureRecognizer.delegate = fullWidthGestureRecognizerDelegate
                    controller.view.addGestureRecognizer(fullWidthBackGestureRecognizer)
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
            layer.root.view().navigationSheetModifiers(for: layer)
        } else {
            layer.root.view()
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

private class FullWidthGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    var navigationController: UINavigationController?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard Settings.get(\.navigation_swipeAnywhere), !UIDevice.isIos26 else { return false }
        let isSystemSwipeToBackEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = (navigationController?.viewControllers.count ?? 0) > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
}
