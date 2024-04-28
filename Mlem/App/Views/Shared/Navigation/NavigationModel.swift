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
            hasNavigationStack: true
        )
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        layers.append(
            .init(
                root: page,
                model: self,
                index: layers.count,
                hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
            )
        )
    }
}
