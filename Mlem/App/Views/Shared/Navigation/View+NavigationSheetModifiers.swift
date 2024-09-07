//
//  NavigationPage+View.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

extension View {
    @ViewBuilder func navigationSheetModifiers(for layer: NavigationLayer) -> some View {
        if let model = layer.model {
            navigationSheetModifiers(
                nextLayer: (layer.index < model.layers.count - 1) ? model.layers[layer.index + 1] : nil,
                model: model
            )
        } else {
            self
        }
    }
        
    // swiftlint:disable:next function_body_length
    @ViewBuilder func navigationSheetModifiers(
        nextLayer: NavigationLayer?,
        model: NavigationModel
    ) -> some View {
        sheet(isPresented: Binding(
            get: { !(nextLayer?.isFullScreenCover ?? true) },
            set: { newValue in
                if !newValue, let nextLayer {
                    model.closeSheets(aboveIndex: nextLayer.index)
                }
            }
        )) {
            if let nextLayer {
                NavigationLayerView(layer: nextLayer, hasSheetModifiers: true)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { nextLayer?.isFullScreenCover ?? false },
            set: { newValue in
                if !newValue, let nextLayer {
                    model.closeSheets(aboveIndex: nextLayer.index)
                }
            }
        )) {
            if let nextLayer {
                NavigationLayerView(layer: nextLayer, hasSheetModifiers: true)
            }
        }
        .photosPicker(
            isPresented: .init(
                get: { nextLayer == nil && model.photosPickerCallback != nil },
                set: { model.photosPickerCallback = $0 ? model.photosPickerCallback : nil }
            ),
            selection: .init(get: { nil }, set: { photo in
                if let photo {
                    model.photosPickerCallback?(photo)
                    model.photosPickerCallback = nil
                }
            }),
            matching: .images
        )
        .fileImporter(
            isPresented: .init(
                get: { nextLayer == nil && model.showingFilePicker },
                set: { model.showingFilePicker = $0 }
            ),
            allowedContentTypes: [.image],
            onCompletion: { result in
                do {
                    try model.filePickerCallback?(result.get())
                } catch {
                    handleError(error)
                }
            }
        )
    }
}
