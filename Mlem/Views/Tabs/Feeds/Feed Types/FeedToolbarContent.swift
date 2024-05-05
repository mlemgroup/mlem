//
//  FeedToolbarContent.swift
//  Mlem
//
//  Created by Sjmarf on 16/03/2024.
//

import Dependencies
import SwiftUI

struct FeedToolbarContent: View {
    @Dependency(\.siteInformation) var siteInformation
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    
    var body: some View {
        ForEach(genEllipsisMenuFunctions()) { menuFunction in
            MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
        }
        Menu {
            ForEach(genPostSizeSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        } label: {
            Label("Post Size", systemImage: Icons.postSizeSetting)
        }
    }
    
    func genEllipsisMenuFunctions() -> [MenuFunction] {
        var body: some ToolbarContent {
            ToolbarItemGroup(placement: .secondaryAction) {
                ForEach(genEllipsisMenuFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
                }
                Menu {
                    ForEach(genPostSizeSwitchingFunctions()) { menuFunction in
                        MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
                    }
                } label: {
                    Label("Post Size", systemImage: Icons.postSizeSetting)
                }
            }
        }
        
        var ret: [MenuFunction] = .init()
        
        if siteInformation.myUserInfo?.localUserView.localUser.showNsfw ?? true {
            let blurNsfwText = shouldBlurNsfw ? "Unblur NSFW" : "Blur NSFW"
            ret.append(MenuFunction.standardMenuFunction(
                text: blurNsfwText,
                imageName: Icons.blurNsfw,
                enabled: true
            ) {
                shouldBlurNsfw.toggle()
            })
        }
        
        let showReadPostsText = showReadPosts ? "Hide Read" : "Show Read"
        ret.append(MenuFunction.standardMenuFunction(
            text: showReadPostsText,
            imageName: "book",
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
                enabled: enabled,
                callback: { postSize = size }
            )
        }
    }
}
