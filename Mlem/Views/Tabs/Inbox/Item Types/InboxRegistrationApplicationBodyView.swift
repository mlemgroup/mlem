//
//  InboxRegistrationApplicationBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Foundation
import SwiftUI

struct InboxRegistrationApplicationBodyView: View {
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    @ObservedObject var application: RegistrationApplicationModel
    let menuFunctions: [MenuFunction]
    
    var iconName: String { application.read ? Icons.registrationApplication : Icons.registrationApplicationFill }
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack(spacing: AppConstants.standardSpacing) {
                UserLinkView(user: application.creator, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(.purple)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: menuFunctions
                )
            }
            
            Text("Applied \(application.published.getRelativeTime())")
                .italic()
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            if let resolver = application.resolver, let approved = application.approved {
                Text(resolutionText(approved: approved, resolver: resolver))
                    .italic()
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            MarkdownView(text: application.application.answer, isNsfw: false)
        }
    }
    
    func resolutionText(approved: Bool, resolver: UserModel) -> String {
        let resolverName: String = resolver.fullyQualifiedUsername ?? resolver.name
        
        if approved {
            return "Approved by \(resolverName)"
        } else {
            var denyReason = ""
            if let reason = application.application.denyReason {
                denyReason = " (\(reason))"
            }
            return "Denied by \(resolverName)\(denyReason)"
        }
    }
}
