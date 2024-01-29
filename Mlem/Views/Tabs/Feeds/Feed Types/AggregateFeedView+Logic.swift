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
        FeedType.allAggregateFeedCases.forEach { type in
            let (imageName, enabled) = type != postTracker.feedType
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            ret.append(MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: enabled,
                callback: {
                    // if switching to a feed that can be handled by AggregateFeedView, just change tracker type; otherwise update nav stack
                    Task {
                        switch type {
                        case .saved:
                            selectedFeed = .saved
                        default:
                            await postTracker.changeFeedType(to: type)
                        }
                    }
                }
            ))
        }
        return ret
    }
}
