//
//  NavigationLayerView.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

struct DeferredContextMenu<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
    }
}

struct NavigationLayerView: View {
    @Bindable var layer: NavigationLayer
    let hasSheetModifiers: Bool
    
    var body: some View {
        Group {
            if layer.hasNavigationStack {
                NavigationStack(path: $layer.path) {
                    DeferredContextMenu {
                        rootView()
                            .environment(\.isRootView, true)
                    }
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
        .confirmationDialog(
            layer.popup?.appearance.label ?? "",
            isPresented: Binding(
                get: { layer.popup != nil },
                set: {
                    if !$0 { layer.dismissPopup() }
                }
            )
        ) {
            ForEach(layer.popup?.children ?? [], id: \.id) { action in
                MenuButton(action: action)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(layer.popup?.prompt ?? "")
        }
        // https://stackoverflow.com/questions/69693871/how-to-open-share-sheet-from-presented-sheet
        .background(SharingViewController(
            isPresenting: Binding(get: { layer.shareUrl != nil }, set: { if !$0 { layer.shareUrl = nil }})
        ) {
            let activityView = UIActivityViewController(
                activityItems: [layer.shareUrl ?? URL(string: "www.apple.com")!],
                applicationActivities: nil
            )
          
            if UIDevice.isPad {
                activityView.popoverPresentationController?.sourceView = UIView()
            }

            activityView.completionWithItemsHandler = { _, _, _, _ in
                layer.shareUrl = nil
            }
            return activityView
        })
        .modifier(HandleLemmyLinksModifier())
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
