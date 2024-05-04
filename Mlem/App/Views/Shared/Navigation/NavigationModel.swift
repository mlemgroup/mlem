//
//  NavigationModel.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

@Observable
class NavigationModel {
    var layers: [NavigationLayer] = .init()

    private func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil, isFullScreenCover: Bool) {
        layers.append(
            .init(
                root: page,
                model: self,
                index: layers.count,
                hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack,
                isFullScreenCover: isFullScreenCover
            )
        )
    }
    
    func addLayer(_ navigationLayer: NavigationLayer) {
        layers.append(navigationLayer)
    }
    
    func closeSheets(aboveIndex index: Int) {
        layers.removeLast(layers.count - index)
    }
    
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: false)
    }
    
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: true)
    }
}
