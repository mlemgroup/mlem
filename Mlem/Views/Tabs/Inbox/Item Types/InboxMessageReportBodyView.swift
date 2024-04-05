//
//  InboxMessageReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxMessageReportBodyView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    
    @ObservedObject var messageReport: MessageReportModel
    
    var iconName: String { messageReport.messageReport.resolved ? Icons.message : Icons.messageFill }
    
    var body: some View {
        content
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
            .contextMenu {
                ForEach(messageReport.genMenuFunctions(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)) { menuFunction in
                    MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
                }
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                HStack(spacing: AppConstants.standardSpacing) {
                    UserLinkView(user: messageReport.reporter, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                    
                    Spacer()
                    
                    Image(systemName: iconName)
                        .foregroundColor(.red)
                        .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                    
                    EllipsisMenu(
                        size: AppConstants.largeAvatarSize,
                        menuFunctions: messageReport.genMenuFunctions(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)
                    )
                }
                
                Text(messageReport.messageReport.reason)
                
                Text("Message reported \(messageReport.published.getRelativeTime())")
                    .italic()
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                if let resolver = messageReport.resolver {
                    let verb = messageReport.messageReport.resolved ? "Resolved" : "Unresolved"
                    Text("\(verb) by \(resolver.fullyQualifiedUsername ?? resolver.name)")
                        .italic()
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                    Text("from \(messageReport.messageCreator.fullyQualifiedUsername ?? messageReport.messageCreator.name)")
                        .font(.footnote)
                    
                    MarkdownView(text: messageReport.messageReport.originalPmText, isNsfw: false, isInline: true)
                }
                .padding(AppConstants.standardSpacing)
                .background {
                    Rectangle()
                        .foregroundColor(.secondarySystemBackground)
                        .cornerRadius(AppConstants.standardSpacing)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.top, AppConstants.standardSpacing)
            .padding(.horizontal, AppConstants.standardSpacing)
            
            InteractionBarView(context: .post, widgets: enrichLayoutWidgets())
        }
    }
    
    func toggleResolved() {
        Task {
            await messageReport.toggleResolved()
        }
    }
    
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.moderator.compactMap { baseWidget in
            switch baseWidget {
            case .resolve:
                return .resolve(resolved: messageReport.messageReport.resolved, resolve: toggleResolved)
            case .ban:
                return .ban(banned: messageReport.messageCreator.banned, instanceBan: true) {
                    messageReport.toggleMessageCreatorBanned(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)
                }
            case .infoStack:
                return .spacer
            default:
                return nil
            }
        }
    }
}
