//
//  InboxMessageReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxMessageReportBodyView: View {
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    
    @ObservedObject var messageReport: MessageReportModel
    
    var iconName: String { messageReport.messageReport.resolved ? Icons.message : Icons.messageFill }
    
    var body: some View {
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
    }
}
