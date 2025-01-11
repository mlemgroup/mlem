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
    
    init(
        nextLayer: NavigationLayer?,
        // This tomfoolery exists to prevent this view being subject to NavigationModel view updates, which caused #1492
        contentPickerTracker: @escaping () -> NavigationModel.ContentPickerTracker?
    ) {
        self.nextLayer = nextLayer
        self.contentPickerTracker_ = contentPickerTracker
    }
    
    // DO NOT access this in the view body; see #1492
    var contentPickerTracker: NavigationModel.ContentPickerTracker? {
        contentPickerTracker_()
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: Binding(
                get: { !(nextLayer?.isFullScreenCover ?? true) },
                set: {
                    if !$0 { closeSheet() }
                }
            )) {
                if let nextLayer {
                    NavigationLayerView(layer: nextLayer, hasSheetModifiers: true)
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { nextLayer?.isFullScreenCover ?? false },
                set: {
                    if !$0 { closeSheet() }
                }
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
                allowedContentTypes: [.image],
                onCompletion: { result in
                    do {
                        try contentPickerTracker?.filePickerCallback?(result.get())
                    } catch {
                        handleError(error)
                    }
                }
            )
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
        contentPickerTracker: @autoclosure @escaping () -> NavigationModel.ContentPickerTracker?
    ) -> some View {
        modifier(NavigationSheetModifier(nextLayer: nextLayer, contentPickerTracker: contentPickerTracker))
    }
}
