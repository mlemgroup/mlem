//
//  NavigationLayerView.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

struct NavigationLayerView: View {
    @Bindable var layer: NavigationLayer
    let hasSheetModifiers: Bool
    
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
