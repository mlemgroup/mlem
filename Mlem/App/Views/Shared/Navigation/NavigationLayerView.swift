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
    @Bindable var layer: NavigationLayer
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
        // https://stackoverflow.com/questions/69693871/how-to-open-share-sheet-from-presented-sheet
        .background(SharingViewController(
            isPresenting: Binding(get: { layer.shareInfo != nil }, set: { if !$0 { layer.shareInfo = nil }})
        ) {
            let activityView = UIActivityViewController(
                activityItems: [layer.shareInfo?.url ?? URL(string: "www.apple.com")!],
                applicationActivities: layer.shareInfo?.activities
            )
          
            if UIDevice.isPad {
                activityView.popoverPresentationController?.sourceView = UIView()
            }

            activityView.completionWithItemsHandler = { _, _, _, _ in
                layer.shareInfo = nil
            }
            return activityView
        })
        .modifier(HandleLemmyLinksModifier())
        .environment(layer)
    }
    
    @ViewBuilder
    private func rootView() -> some View {
        if hasSheetModifiers {
            layer.root.view().navigationSheetModifiers(for: layer)
        } else {
            layer.root.view()
        }
    }
}

private struct SharingViewController: UIViewControllerRepresentable {
    @Binding var isPresenting: Bool
    var content: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: { isPresenting = false })
        }
    }
}

private class FullWidthGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    var navigationController: UINavigationController?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !Settings.main.swipeAnywhereToNavigate { return false }
        let isSystemSwipeToBackEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = (navigationController?.viewControllers.count ?? 0) > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
}
