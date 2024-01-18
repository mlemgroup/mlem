//
//  PostFeedView+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import Foundation

extension NewPostFeedView {
    func genOuterSortMenuFunctions() -> [MenuFunction] {
        PostSortType.availableOuterTypes.map { type in
            let isSelected = postSortType == type
            let imageName = isSelected ? type.iconNameFill : type.iconName
            return MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: !isSelected
            ) {
                postSortType = type
            }
        }
    }
    
    func genTopSortMenuFunctions() -> [MenuFunction] {
        PostSortType.availableTopTypes.map { type in
            let isSelected = postSortType == type
            return MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: isSelected ? Icons.timeSortFill : Icons.timeSort,
                destructiveActionPrompt: nil,
                enabled: !isSelected
            ) {
                postSortType = type
            }
        }
    }
    
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
        
        let showReadPostsText = showReadPosts ? "Hide Read" : "Show Read"
        ret.append(MenuFunction.standardMenuFunction(
            text: showReadPostsText,
            imageName: "book",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            showReadPosts.toggle()
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
