//
//  CommentSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-11.
//

import Foundation
import SwiftUI

enum JumpButtonLocation: String, SettingsOptions {
    case bottomLeading, bottomTrailing, center
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .bottomLeading:
            return "Left"
        case .bottomTrailing:
            return "Right"
        case .center:
            return "Center"
        }
    }
    
    var alignment: Alignment {
        switch self {
        case .bottomLeading:
            return .bottomLeading
        case .bottomTrailing:
            return .bottomTrailing
        case .center:
            return .bottom
        }
    }
}

struct CommentSettingsView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @AppStorage("compactComments") var compactComments: Bool = false
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = true
    
    // interactions and info
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    @AppStorage("showCommentJumpButton") var showCommentJumpButton: Bool = true
    @AppStorage("collapseChildComments") var collapseChildComments: Bool = false
    @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.compactPost,
                    settingName: "Compact Comments",
                    isTicked: $compactComments
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.collapseComments,
                    settingName: "Collapse Comments",
                    isTicked: $collapseChildComments
                )
                
                NavigationLink(.commentSettings(.layoutWidget)) {
                    Label {
                        Text("Customize Widgets")
                    } icon: {
                        if showSettingsIcons {
                            Image(systemName: Icons.widgetWizard)
                                .foregroundColor(.pink)
                        }
                    }
                }
            } footer: {
                Text("Comment widgets are visible when 'Compact Comments' is off.")
            }

            Section("Interactions and Info") {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.instance,
                    settingName: "Show User Server Instance",
                    isTicked: $shouldShowUserServerInComment
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.upvoteSquare,
                    settingName: "Show Score In Info",
                    isTicked: $shouldShowScoreInCommentBar
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.votesSquare,
                    settingName: "Show Downvotes Separately",
                    isTicked: $showCommentDownvotesSeparately
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.time,
                    settingName: "Show Time Posted In Info",
                    isTicked: $shouldShowTimeInCommentBar
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.save,
                    settingName: "Show Saved Status In Info",
                    isTicked: $shouldShowSavedInCommentBar
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.replies,
                    settingName: "Show Replies In Info",
                    isTicked: $shouldShowRepliesInCommentBar
                )
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.jumpButtonCircle,
                    settingName: "Show Jump Button",
                    isTicked: $showCommentJumpButton
                )
                SelectableSettingsItem(
                    settingIconSystemName: Icons.leftRight,
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
        .hoistNavigation()
    }
}
