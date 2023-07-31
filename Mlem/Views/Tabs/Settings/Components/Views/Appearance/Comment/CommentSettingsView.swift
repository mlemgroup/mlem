//
//  CustomizeCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-11.
//

import Foundation
import SwiftUI

struct CommentSettingsView: View {
    
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    @AppStorage("compactComments") var compactComments: Bool = false
    // interactions and info
    @AppStorage("commentVoteComplexStyle") var commentVoteComplexStyle: VoteComplexStyle = .plain
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    var body: some View {
        List {
            Section("Comment Size") {
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.compactSymbolName,
                                       settingPictureColor: .pink,
                                       settingName: "Compact comments",
                                       isTicked: $compactComments)
            }
            
            Section("Display Sides") {
                SwitchableSettingsItem(settingPictureSystemName: "arrow.up.arrow.down",
                                       settingPictureColor: .pink,
                                       settingName: "Show vote buttons on right",
                                       isTicked: $shouldShowVoteComplexOnRight)
            }

            Section("Interactions and Info") {
                SelectableSettingsItem(
                    settingIconSystemName: "arrow.up.arrow.down.square",
                    settingName: "Vote complex style",
                    currentValue: $commentVoteComplexStyle,
                    options: VoteComplexStyle.allCases
                )
                SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                                           settingPictureColor: .pink,
                                                           settingName: "Show user server instance",
                                                           isTicked: $shouldShowUserServerInComment)
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.emptyUpvoteSymbolName,
                                       settingPictureColor: .pink,
                                       settingName: "Show score in info",
                                       isTicked: $shouldShowScoreInCommentBar)
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.generalVoteSymbolName,
                                       settingPictureColor: .pink,
                                       settingName: "Show downvotes separately",
                                       isTicked: $showCommentDownvotesSeparately)
                SwitchableSettingsItem(settingPictureSystemName: "clock",
                                       settingPictureColor: .pink,
                                       settingName: "Show time posted in info",
                                       isTicked: $shouldShowTimeInCommentBar)
                SwitchableSettingsItem(settingPictureSystemName: "bookmark",
                                       settingPictureColor: .pink,
                                       settingName: "Show saved status in info",
                                       isTicked: $shouldShowSavedInCommentBar)
                SwitchableSettingsItem(settingPictureSystemName: "bubble.right",
                                       settingPictureColor: .pink,
                                       settingName: "Show replies in info",
                                       isTicked: $shouldShowRepliesInCommentBar)
            }
        }
        .fancyTabScrollCompatible()
    }
}
