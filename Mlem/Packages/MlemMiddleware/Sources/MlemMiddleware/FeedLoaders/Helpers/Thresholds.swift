//
//  Thresholds.swift
//
//
//  Created by Eric Andrews on 2024-07-22.
//

import Foundation

struct Thresholds<Item: FeedLoadable> {
    var standard: Item?
    var fallback: Item?
    
    func isThreshold(_ item: Item) -> Bool {
        item == standard || item == fallback
    }
    
    mutating func update(with newItems: [Item]) {
        if newItems.count < MiddlewareConstants.infiniteLoadThresholdOffset {
            standard = nil
            fallback = nil
        } else {
            standard = newItems[newItems.count - MiddlewareConstants.infiniteLoadThresholdOffset]
            fallback = newItems.last
        }
    }
}
