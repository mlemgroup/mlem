//
//  SwipeConfiguration.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-11.
//

import Foundation

public enum SwipeBuffer {
    case none, tile, standard
    
    var value: CGFloat {
        switch self {
        case .none: 0
        case .tile: 50
        case .standard: 70
        }
    }
}

public struct SwipeConfiguration {
    /// In ascending order of appearance.
    public let leadingActions: [QuickSwipeAction]
    /// In ascending order of appearance.
    public let trailingActions: [QuickSwipeAction]
    
    public let leadingBuffer: SwipeBuffer
    
    public init(
        leadingActions: [QuickSwipeAction] = [],
        trailingActions: [QuickSwipeAction] = [],
        leadingBuffer: SwipeBuffer
    ) {
        assert(
            leadingActions.count <= 3 && trailingActions.count <= 3,
            "Too many swipe actions!"
        )
        
        self.leadingActions = leadingActions.filter(\.enabled)
        self.trailingActions = trailingActions.filter(\.enabled)
        self.leadingBuffer = leadingBuffer
    }
}
