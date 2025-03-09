//
//  InboxView+Types.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import SwiftUI
import Theming

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
        
        var color: ThemedColor {
            switch self {
            case .inbox: .themedInbox
            case .modMail: .themedModeration
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
    
    enum ModTab: CaseIterable, Identifiable {
        case reports, applications
        
        var id: ModTab { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .reports: "Reports"
            case .applications: "Applications"
            }
        }
    }
}
