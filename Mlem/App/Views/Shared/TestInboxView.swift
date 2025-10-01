//
//  TestInboxView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-01.
//

import MlemMiddleware
import SwiftUI

// This view is for testing only and will be removed once the notification system is working
struct TestInboxView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(NotifType.allCases, id: \.self) { type in
                    TestInboxSectionView(type: type)
                }
            }
        }
        .themedGroupedBackground()
    }
}

private enum NotifType: String, CaseIterable {
    case reply, mention, message
}

private struct TestInboxSectionView: View {
    @Environment(AppState.self) var appState
    
    let type: NotifType
    
    @State var notifications: [InboxNotification]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(type.rawValue)
            if let notifications {
                ForEach(notifications) { notification in
                    Text(String(notification.id))
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(.themedSecondaryGroupedBackground, in: .capsule)
                }
            }
        }
        .task { await load() }
    }
    
    func load() async {
        do {
            switch type {
            case .reply:
                notifications = try await appState.firstApi.getReplyNotifications()
            case .mention:
                notifications = try await appState.firstApi.getMentionNotifications()
            case .message:
                notifications = try await appState.firstApi.getMessageNotifications()
            }
        } catch {
            handleError(error)
        }
    }
}
