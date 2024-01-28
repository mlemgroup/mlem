//
//  UserContentFeedView+MenuFunctions.swift
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
}
