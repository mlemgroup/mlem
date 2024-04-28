//
//  NavigationLayer.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import SwiftUI

@Observable
class NavigationLayer {
    weak var model: NavigationModel?
    var index: Int
    
    var root: NavigationPage
    var path: NavigationPath = .init()
    var hasNavigationStack: Bool
    
    init(
        root: NavigationPage,
        model: NavigationModel,
        index: Int,
        hasNavigationStack: Bool
    ) {
        self.model = model
        self.index = index
        self.root = root
        self.hasNavigationStack = hasNavigationStack
    }
    
    func push(_ page: NavigationPage) {
        path.append(page)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.openSheet(page, hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack)
    }
}
