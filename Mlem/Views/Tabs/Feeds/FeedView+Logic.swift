//
//  FeedView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import SwiftUI

extension FeedView {
    func genFeedSwitchingFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        FeedType.allCases.forEach { type in
            let (imageName, enabled) = type != feedType
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            ret.append(MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: enabled,
                callback: { feedType = type }
            ))
        }
        return ret
    }
}
