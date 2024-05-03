//
//  NavigationModel.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

@Observable
class NavigationModel {
    var rootLayer: NavigationLayer!
    var layers: [NavigationLayer] = .init()
    
    init(root: NavigationPage) {
        self.rootLayer = NavigationLayer(
            root: root,
            model: self,
            index: -1,
            hasNavigationStack: true,
            isFullScreenCover: false
        )
    }

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
