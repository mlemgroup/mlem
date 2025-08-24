//
//  SwipeBehavior.swift
//  QuickSwipes
//
//  Created by Sjmarf on 2025-08-22.
//

import Foundation

public struct QuickSwipeThresholdSet {
    /// Minimum distance to trigger the primary action
    public let primary: CGFloat
    /// Minimum distance to trigger the secondary action
    public let secondary: CGFloat
    /// Minimum distance to trigger the tertiary action
    public let tertiary: CGFloat
    
    public var all: [CGFloat] { [primary, secondary, tertiary] }
    
    public init(primary: CGFloat, secondary: CGFloat, tertiary: CGFloat) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
    
    public static var `default`: QuickSwipeThresholdSet {
        .init(primary: 60, secondary: 150, tertiary: 240)
    }
}
