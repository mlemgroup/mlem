//
//  NavigationModel.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import PhotosUI
import SwiftUI

@Observable
class NavigationModel {
    static let main: NavigationModel = .init()
    
    private(set) var layers: [NavigationLayer] = .init()
    
    var photosPickerCallback: ((PhotosPickerItem) -> Void)?
    
    // This needs two values unlike `photosPickerCallback` because
    // `fileImporter` sets `isPresented` to `false` before calling
    // `onCompletion`, which makes it impossible to call the callback
    // before setting it to `nil`.
    var showingFilePicker: Bool = false
    var filePickerCallback: ((URL) -> Void)?
    
    private func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil, isFullScreenCover: Bool) {
        layers.append(
            .init(
                root: page,
                model: self,
                index: layers.count,
                hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack,
                isFullScreenCover: isFullScreenCover,
                canDisplayToasts: page.canDisplayToasts
            )
        )
    }
    
    func addLayer(_ navigationLayer: NavigationLayer) {
        layers.append(navigationLayer)
    }
    
    // Closes all sheets above and including the given index
    func closeSheets(aboveIndex index: Int) {
        for layer in layers.dropFirst(index) {
            layer.model = nil
        }
        layers.removeLast(layers.count - index)
    }
    
    func clear() {
        layers.forEach { $0.model = nil }
        layers = []
    }
    
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: false)
    }
    
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: true)
    }
}
