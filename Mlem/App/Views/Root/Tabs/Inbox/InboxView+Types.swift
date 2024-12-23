//
//  InboxView+Types.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import SwiftUI

extension InboxView {
    enum Feed: CaseIterable, Identifiable {
        case inbox, modMail
        
        var id: Feed { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .inbox: "Inbox"
            case .modMail: "Mod Mail"
            }
        }
        
        func subtitle(isAdmin: Bool) -> LocalizedStringResource {
            switch self {
            case .inbox:
                return "Replies, mentions and messages"
            case .modMail:
                if isAdmin {
                    return "Reports and Registration Applications"
                } else {
                    return "Reports from communities you moderate"
                }
            }
        }
        
        var systemImage: String {
            switch self {
            case .inbox: Icons.inbox
            case .modMail: Icons.moderation
            }
        }
        
        var systemImageFill: String {
            switch self {
            case .inbox: Icons.inboxFill
            case .modMail: Icons.moderationFill
            }
        }
        
        var color: Color {
            switch self {
            case .inbox: Palette.main.inbox
            case .modMail: Palette.main.moderation
            }
        }
    }
    
    enum Tab: CaseIterable, Identifiable {
        case all, replies, mentions, messages
        
        var id: Tab { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .all: "All"
            case .replies: "Replies"
            case .mentions: "Mentions"
            case .messages: "Messages"
            }
        }
    }
}
