//
//  InboxMessageReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxMessageReportBodyView: View {
    @ObservedObject var messageReport: MessageReportModel
    
    var iconName: String { messageReport.messageReport.resolved ? Icons.message : Icons.messageFill }
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack(spacing: AppConstants.standardSpacing) {
                UserLinkView(user: messageReport.reporter, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(.red)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: .init() // TODO: NEXT
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
            
            MarkdownView(text: messageReport.messageReport.originalPmText, isNsfw: false, isInline: true)
                .padding(AppConstants.standardSpacing)
                .background {
                    Rectangle()
                        .foregroundColor(.secondarySystemBackground)
                        .cornerRadius(AppConstants.standardSpacing)
                }
                .foregroundStyle(.secondary)
        }
    }
}
