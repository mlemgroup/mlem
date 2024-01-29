//
//  UserContentFeedView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation

extension UserContentFeedView {
    func genPostSizeSwitchingFunctions() -> [MenuFunction] {
        PostSize.allCases.map { size in
            let (imageName, enabled) = size != postSize
                ? (size.iconName, true)
                : (size.iconNameFill, false)
            
            return MenuFunction.standardMenuFunction(
                text: size.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: enabled,
                callback: { postSize = size }
            )
        }
    }
    
    func genFeedSwitchingFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        FeedType.allAggregateFeedCases.forEach { type in
            let (imageName, enabled) = type != .saved
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            ret.append(MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: enabled,
                callback: {
                    selectedFeed = type
                }
            ))
        }
        return ret
    }
}
