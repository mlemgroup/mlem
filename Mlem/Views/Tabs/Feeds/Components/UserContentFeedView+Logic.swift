//
//  UserContentFeedView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation

extension UserContentFeedView {
    func genEllipsisMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        let blurNsfwText = shouldBlurNsfw ? "Unblur NSFW" : "Blur NSFW"
        ret.append(MenuFunction.standardMenuFunction(
            text: blurNsfwText,
            imageName: Icons.blurNsfw,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            shouldBlurNsfw.toggle()
        })
        
        return ret
    }
    
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
