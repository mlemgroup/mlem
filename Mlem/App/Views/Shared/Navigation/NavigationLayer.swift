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
    var path: [NavigationPage] = .init()
    var hasNavigationStack: Bool
    var isFullScreenCover: Bool
    var canDisplayToasts: Bool
    
    init(
        root: NavigationPage,
        model: NavigationModel,
        index: Int = -1,
        hasNavigationStack: Bool = true,
        isFullScreenCover: Bool = false,
        canDisplayToasts: Bool = true
    ) {
        self.model = model
        self.index = index
        self.root = root
        self.hasNavigationStack = hasNavigationStack
        self.isFullScreenCover = isFullScreenCover
        self.canDisplayToasts = canDisplayToasts
    }
    
    func push(_ page: NavigationPage) {
        path.append(page)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
        if path.isEmpty, index != -1 {
            model?.closeSheets(aboveIndex: index)
        }
    }
    
    func dismissSheet() {
        model?.closeSheets(aboveIndex: index)
    }
    
    var isTopSheet: Bool {
        isInsideSheet && index == (model?.layers.count ?? 0) - 1
    }
    
    var isToastDisplayer: Bool {
        isInsideSheet
            && canDisplayToasts
            && model?.layers.last(where: { $0.canDisplayToasts }) === self
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.openSheet(
            page,
            hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
        )
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.showFullScreenCover(
            page,
            hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
        )
    }
    
    var isInsideSheet: Bool { index != -1 }
}
