//
//  NavigationPage+View.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

private struct NavigationSheetModifier: ViewModifier {
    let nextLayer: NavigationLayer?
    let contentPickerTracker_: () -> NavigationModel.ContentPickerTracker?
    let isTopSheet: Bool
    
    @Binding var shareInfo: NavigationModel.ShareInfo?
    
    init(
        nextLayer: NavigationLayer?,
        isTopSheet: Bool,
        shareInfo: Binding<NavigationModel.ShareInfo?>,
        // This tomfoolery exists to prevent this view being subject to NavigationModel view updates, which caused #1492
        contentPickerTracker: @escaping () -> NavigationModel.ContentPickerTracker?
    ) {
        self.nextLayer = nextLayer
        self.isTopSheet = isTopSheet
        self._shareInfo = shareInfo
        self.contentPickerTracker_ = contentPickerTracker
    }
    
    // DO NOT access this in the view body; see #1492
    var contentPickerTracker: NavigationModel.ContentPickerTracker? {
        contentPickerTracker_()
    }
    
    func body(content: Content) -> some View {
        content
            // https://stackoverflow.com/questions/69693871/how-to-open-share-sheet-from-presented-sheet
            .background(SharingViewController(
                isPresenting: Binding(get: { shareInfo != nil && isTopSheet }, set: { if !$0 { shareInfo = nil }})
            ) { activityViewController }
            )
            .sheet(isPresented: Binding(
                get: { !(nextLayer?.isFullScreenCover ?? true) },
                set: { if !$0 { closeSheet() } }
            )) {
                if let nextLayer {
                    NavigationLayerView(layer: nextLayer, hasSheetModifiers: true)
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { nextLayer?.isFullScreenCover ?? false },
                set: { if !$0 { closeSheet() } }
            )) {
                if let nextLayer {
                    NavigationLayerView(layer: nextLayer, hasSheetModifiers: true)
                }
            }
            .photosPicker(
                isPresented: .init(
                    get: { nextLayer == nil && contentPickerTracker?.photosPickerCallback != nil },
                    set: { contentPickerTracker?.photosPickerCallback = $0 ? contentPickerTracker?.photosPickerCallback : nil }
                ),
                selection: .init(get: { nil }, set: { photo in
                    if let photo {
                        contentPickerTracker?.photosPickerCallback?(photo)
                        contentPickerTracker?.photosPickerCallback = nil
                    }
                }),
                matching: .images
            )
            .fileImporter(
                isPresented: .init(
                    get: { nextLayer == nil && (contentPickerTracker?.showingFilePicker ?? false) },
                    set: { contentPickerTracker?.showingFilePicker = $0 }
                ),
                allowedContentTypes: contentPickerTracker?.filePickerContentTypes ?? [],
                onCompletion: { result in
                    do {
                        try contentPickerTracker?.filePickerCallback?(result.get())
                    } catch {
                        handleError(error)
                    }
                }
            )
    }
    
    var activityViewController: UIActivityViewController {
        let activityView = UIActivityViewController(
            activityItems: [shareInfo?.url ?? URL(string: "www.apple.com")!],
            applicationActivities: shareInfo?.activities
        )
        
        if UIDevice.isPad {
            activityView.popoverPresentationController?.sourceView = UIView()
        }
        
        activityView.completionWithItemsHandler = { _, _, _, _ in
            shareInfo = nil
        }
        return activityView
    }
    
    func closeSheet() {
        if let nextLayer, let model = nextLayer.model {
            model.closeSheets(aboveIndex: nextLayer.index)
        }
    }
}

private struct ComputeNextLayerModifier: ViewModifier {
    let layer: NavigationLayer
    
    // This exists to prevent the view from being subject to NavigationModel state updates, which caused #1492
    @State var nextLayer: NavigationLayer?
    
    func body(content: Content) -> some View {
        Group {
            content.navigationSheetModifiers(
                nextLayer: nextLayer,
                isTopSheet: layer.isTopSheet,
                shareInfo: .init(get: { layer.model?.shareInfo }, set: { layer.model?.shareInfo = $0 }),
                contentPickerTracker: layer.model?.contentPickerTracker
            )
        }.onChange(of: computeNextLayer()?.id, initial: true) {
            nextLayer = computeNextLayer()
        }
    }
    
    func computeNextLayer() -> NavigationLayer? {
        if let model = layer.model {
            (layer.index < model.layers.count - 1) ? model.layers[layer.index + 1] : nil
        } else {
            nil
        }
    }
}

extension View {
    @ViewBuilder func navigationSheetModifiers(for layer: NavigationLayer) -> some View {
        modifier(ComputeNextLayerModifier(layer: layer))
    }
        
    @ViewBuilder func navigationSheetModifiers(
        nextLayer: NavigationLayer?,
        isTopSheet: Bool,
        shareInfo: Binding<NavigationModel.ShareInfo?>,
        contentPickerTracker: @autoclosure @escaping () -> NavigationModel.ContentPickerTracker?
    ) -> some View {
        modifier(NavigationSheetModifier(
            nextLayer: nextLayer,
            isTopSheet: isTopSheet,
            shareInfo: shareInfo,
            contentPickerTracker: contentPickerTracker
        ))
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
