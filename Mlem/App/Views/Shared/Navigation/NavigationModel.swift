//
//  NavigationModel.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

@Observable
class NavigationModel {
    static let main: NavigationModel = .init()
    
    var layers: [NavigationLayer] = .init()
    
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
    
    func closeSheets(aboveIndex index: Int) {
        guard layers.count - index >= 0 else {
            print("Cannot remove above \(index), only \(layers.count) layers")
            return
        }
        layers.removeLast(layers.count - index)
    }
    
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: false)
    }
    
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: true)
    }
}
