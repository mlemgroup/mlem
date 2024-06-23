//
//  PostEllipsisMenus.swift
//  Mlem
//
//  Created by Sjmarf on 26/03/2024.
//

import Dependencies
import SwiftUI

struct PostEllipsisMenus: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
    @AppStorage("postSize") var postSize: PostSize = .large
    
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    let postModel: PostModel
    let postTracker: StandardPostTracker?
    
    var size: CGFloat = 24
    
    var isMod: Bool {
        siteInformation.isModOrAdmin(communityId: postModel.community.communityId)
    }
    
    var combinedMenuFunctions: [MenuFunction] {
        postModel.combinedMenuFunctions(
            editorTracker: editorTracker,
            showSelectText: postSize == .large,
            postTracker: postTracker,
            community: isMod ? postModel.community : nil,
            modToolTracker: isMod ? modToolTracker : nil
        )
    }

    var onlyPersonalMenuFunctions: [MenuFunction] {
        postModel.personalMenuFunctions(
            editorTracker: editorTracker,
            showSelectText: postSize == .large,
            postTracker: postTracker,
            community: isMod ? postModel.community : nil,
            modToolTracker: isMod ? modToolTracker : nil
        )
    }
    
    var onlyModeratorMenuFunctions: [MenuFunction] {
        postModel.modMenuFunctions(
            community: postModel.community,
            modToolTracker: modToolTracker,
            postTracker: postTracker
        )
    }
    
    var body: some View {
        if moderatorActionGrouping == .separateMenu {
            if isMod {
                let functions = onlyModeratorMenuFunctions
                EllipsisMenu(
                    size: size,
                    systemImage: siteInformation.isAdmin ? Icons.admin : Icons.moderation,
                    menuFunctions: functions
                )
                .opacity(functions.isEmpty ? 0.5 : 1)
            }
            EllipsisMenu(size: size, menuFunctions: onlyPersonalMenuFunctions)
        } else {
            EllipsisMenu(size: size, menuFunctions: combinedMenuFunctions)
        }
    }
}
