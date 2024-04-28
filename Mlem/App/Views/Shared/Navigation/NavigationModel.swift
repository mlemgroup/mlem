//
//  NavigationModel.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

@Observable
class NavigationModel {
    var root: NavigationLayer!
    var layers: [NavigationLayer] = .init()
    
    init(root: NavigationPage) {
        self.root = NavigationLayer(
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

@Observable
class NavigationLayer {
    weak var model: NavigationModel?
    var index: Int
    
    private(set) var root: NavigationPage
    var path: [NavigationPage]?
    
    init(
        root: NavigationPage,
        model: NavigationModel,
        index: Int,
        hasNavigationStack: Bool
    ) {
        self.root = root
        self.model = model
        self.index = index
        self.path = hasNavigationStack ? .init() : nil
    }
    
    func push(_ page: NavigationPage) {
        path?.append(page)
    }
    
    func pop() {
        if !(path?.isEmpty ?? false) {
            path?.removeLast()
        }
    }
    
    func popToRoot() {
        path?.removeAll()
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.openSheet(page, hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack)
    }
}
