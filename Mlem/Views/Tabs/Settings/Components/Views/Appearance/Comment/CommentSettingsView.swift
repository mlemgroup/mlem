//
//  CustomizeCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-11.
//

import Foundation
import SwiftUI

struct CommentSettingsView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @AppStorage("compactComments") var compactComments: Bool = false
    // interactions and info
    @AppStorage("commentVoteComplexStyle") var commentVoteComplexStyle: VoteComplexStyle = .plain
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    @State private var showingWidgetSheet = false
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.compactSymbolName,
                                       settingName: "Compact Comments",
                                       isTicked: $compactComments)
                
                Button {
                    showingWidgetSheet = true
                } label: {
                    HStack {
                        Text("Customize widgets")
                        Spacer()
                        Image(systemName: "arrow.up.square.fill")
                        Image(systemName: "arrow.down.square")
                    }
                    .foregroundStyle(.pink)
                }
            } footer: {
                Text("Comment widgets are visible when 'Compact comments' is off.")
            }

            Section("Interactions and Info") {
                SelectableSettingsItem(
                    settingIconSystemName: "arrow.up.arrow.down.square",
                    settingName: "Vote Buttons",
                    currentValue: $commentVoteComplexStyle,
                    options: VoteComplexStyle.allCases
                )
                SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                       settingName: "Show User Server Instance",
                                       isTicked: $shouldShowUserServerInComment)
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.emptyUpvoteSymbolName,
                                       settingName: "Show Score In Info",
                                       isTicked: $shouldShowScoreInCommentBar)
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.generalVoteSymbolName,
                                       settingName: "Show Downvotes Separately",
                                       isTicked: $showCommentDownvotesSeparately)
                SwitchableSettingsItem(settingPictureSystemName: "clock",
                                       settingName: "Show Time Posted In Info",
                                       isTicked: $shouldShowTimeInCommentBar)
                SwitchableSettingsItem(settingPictureSystemName: "bookmark",
                                       settingName: "Show Saved Status In Info",
                                       isTicked: $shouldShowSavedInCommentBar)
                SwitchableSettingsItem(settingPictureSystemName: "bubble.right",
                                       settingName: "Show Replies In Info",
                                       isTicked: $shouldShowRepliesInCommentBar)
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingWidgetSheet) {
            PostLayoutEditView($showingWidgetSheet, widgets: layoutWidgetTracker.groups!.comment, onSave: { widgets in
                layoutWidgetTracker.groups?.comment = widgets
                layoutWidgetTracker.saveToDisk()
            })
                .interactiveDismissDisabled()
        }
    }
}
