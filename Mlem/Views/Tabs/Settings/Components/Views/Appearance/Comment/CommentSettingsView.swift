//
//  CommentSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-11.
//

import Foundation
import SwiftUI

enum JumpButtonLocation: String, SettingsOptions {
    case bottomLeading, bottomTrailing
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .bottomLeading:
            return "Left"
        case .bottomTrailing:
            return "Right"
        }
    }
}

struct CommentSettingsView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @AppStorage("compactComments") var compactComments: Bool = false
    // interactions and info
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    @AppStorage("showCommentJumpButton") var showCommentJumpButton: Bool = true
    @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: AppConstants.compactSymbolName,
                    settingName: "Compact Comments",
                    isTicked: $compactComments
                )
                
                NavigationLink(value: CommentSettingsRoute.layoutWidget) {
                    Label {
                        Text("Customize Widgets")
                    } icon: {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.pink)
                    }
                }
            } footer: {
                Text("Comment widgets are visible when 'Compact Comments' is off.")
            }

            Section("Interactions and Info") {
                SwitchableSettingsItem(
                    settingPictureSystemName: "server.rack",
                    settingName: "Show User Server Instance",
                    isTicked: $shouldShowUserServerInComment
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: AppConstants.emptyUpvoteSymbolName,
                    settingName: "Show Score In Info",
                    isTicked: $shouldShowScoreInCommentBar
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: AppConstants.generalVoteSymbolName,
                    settingName: "Show Downvotes Separately",
                    isTicked: $showCommentDownvotesSeparately
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: "clock",
                    settingName: "Show Time Posted In Info",
                    isTicked: $shouldShowTimeInCommentBar
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: "bookmark",
                    settingName: "Show Saved Status In Info",
                    isTicked: $shouldShowSavedInCommentBar
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: "bubble.right",
                    settingName: "Show Replies In Info",
                    isTicked: $shouldShowRepliesInCommentBar
                )
            }
            
            Section {
                SwitchableSettingsItem(settingPictureSystemName: "circle",
                                       settingName: "Show Jump Button",
                                       isTicked: $showCommentJumpButton)
                SelectableSettingsItem(
                    settingIconSystemName: "arrow.left.arrow.right",
                    settingName: "Side",
                    currentValue: $commentJumpButtonSide,
                    options: JumpButtonLocation.allCases
                )
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Comments")
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
    }
}
