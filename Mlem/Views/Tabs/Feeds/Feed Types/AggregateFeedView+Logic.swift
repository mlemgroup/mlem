//
//  AggregateFeedView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-20.
//

import Foundation

extension AggregateFeedView {
    func genFeedSwitchingFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        availableFeeds.forEach { type in
            let (imageName, enabled) = type != selectedFeed
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            ret.append(MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                role: nil,
                enabled: enabled,
                callback: {
                    // when switching back from the saved feed, stale items are sometimes present in the post tracker; this ensures that those are not displayed
                    if selectedFeed == .saved, type != postTracker.feedType {
                        postTracker.isStale = true
                    }
                    
                    selectedFeed = type
                }
            ))
        }
        return ret
    }
}
