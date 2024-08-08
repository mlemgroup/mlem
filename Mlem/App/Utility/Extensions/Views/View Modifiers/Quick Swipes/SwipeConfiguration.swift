//
//  SwipeConfiguration.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-11.
//

import Foundation

public struct SwipeConfiguration {
    /// In ascending order of appearance.
    let leadingActions: [any Action]
    /// In ascending order of appearance.
    let trailingActions: [any Action]
    
    let behavior: SwipeBehavior
    
    init(
        behavior: SwipeBehavior = .standard,
        leadingActions: [any Action] = [],
        trailingActions: [any Action] = []
    ) {
        assert(
            leadingActions.count <= 3 && trailingActions.count <= 3,
            "Too many swipe actions!"
        )
        self.leadingActions = leadingActions.compactMap { $0 }
        self.trailingActions = trailingActions.compactMap { $0 }
        self.behavior = behavior
    }
    
    init(
        behavior: SwipeBehavior = .standard,
        @ActionBuilder leadingActions: () -> [any Action] = { [] },
        @ActionBuilder trailingActions: () -> [any Action] = { [] }
    ) {
        self.init(
            behavior: behavior,
            leadingActions: leadingActions(),
            trailingActions: trailingActions()
        )
    }
}

struct SwipeBehavior {
    /// Minimum distance to trigger the primary action
    let primaryThreshold: CGFloat
    /// Minimum distance to trigger the secondary action
    let secondaryThreshold: CGFloat
    /// Minimum distance to trigger the tertiary action
    let tertiaryThreshold: CGFloat
    
    var thresholds: [CGFloat] { [primaryThreshold, secondaryThreshold, tertiaryThreshold] }
    
    /// Minimum distance to trigger drag gesture
    let minimumDrag: CGFloat
    
    /// Corner radius to clip the swipe view into
    let cornerRadius: CGFloat
    
    /// Font size for the icon
    let iconSize: CGFloat
    
    static let standard: SwipeBehavior = .init(
        primaryThreshold: 60,
        secondaryThreshold: 150,
        tertiaryThreshold: 240,
        minimumDrag: 20,
        cornerRadius: 0,
        iconSize: 28
    )
    
    static let tile: SwipeBehavior = .init(
        primaryThreshold: 40,
        secondaryThreshold: 100,
        tertiaryThreshold: 160,
        minimumDrag: 10,
        cornerRadius: Constants.main.largeItemCornerRadius,
        iconSize: 18
    )
}
