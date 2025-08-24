//
//  File.swift
//  QuickSwipes
//
//  Created by Sjmarf on 2025-08-22.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var quickSwipeThresholdSet: QuickSwipeThresholdSet = .default
    @Entry var quickSwipeMinimumDrag: CGFloat = 20
    @Entry var quickSwipeIconSize: CGFloat = 16
    @Entry var quickSwipeCornerRadius: CGFloat = 28
    @Entry var quickSwipesEnabled: Bool = true
}
