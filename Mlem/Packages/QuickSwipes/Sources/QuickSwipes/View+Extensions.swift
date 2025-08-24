//
//  File.swift
//  QuickSwipes
//
//  Created by Sjmarf on 2025-08-22.
//

import SwiftUI

public extension View {
    func quickSwipeThresholds(_ thresholdSet: QuickSwipeThresholdSet) -> some View {
        environment(\.quickSwipeThresholdSet, thresholdSet)
    }
    
    func quickSwipeThresholds(primary: CGFloat, secondary: CGFloat, tertiary: CGFloat) -> some View {
        environment(\.quickSwipeThresholdSet, .init(primary: primary, secondary: secondary, tertiary: tertiary))
    }
    
    func quickSwipeMinimumDrag(_ minimumDrag: CGFloat) -> some View {
        environment(\.quickSwipeMinimumDrag, minimumDrag)
    }
    
    func quickSwipeIconSize(_ iconSize: CGFloat) -> some View {
        environment(\.quickSwipeIconSize, iconSize)
    }
    
    func quickSwipeCornerRadius(_ cornerRadius: CGFloat) -> some View {
        environment(\.quickSwipeCornerRadius, cornerRadius)
    }
    
    func quickSwipesDisabled(_ disabled: Bool = true) -> some View {
        environment(\.quickSwipesEnabled, !disabled)
    }
}
