//
//  TestInboxView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-01.
//

import Actions
import MlemMiddleware
import SwiftUI
import QuickSwipes

// This view is for testing only and will be removed once the notification system is working
struct TestInboxView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(NotifType.allCases, id: \.self) { type in
                    TestInboxSectionView(type: type)
                }
            }
            .padding(.horizontal, 10)
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
                ForEach(notifications, content: self.item)
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    func item(_ notification: InboxNotification) -> some View {
            itemBody(notification)
                .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 10))
            .contextMenu(notification: notification)
            .quickSwipes(leading: [], trailing: [MarkReadAction(notification: notification)])
            .popupAnchor()
            .onTapGesture {
                Task {
                    notification.toggleRead()
                }
            }
    }

    @ViewBuilder
    func itemBody(_ notification: InboxNotification) -> some View {
        VStack {
            if notification.read {
                Image(icon: .general.success)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            switch notification.content {
            case let .reply(comment):
                Text(comment.content)
            case let .mention(comment):
                Text(comment.content)
            case let .message(message):
                Text(message.content)
            }
        }
    }
    
    func load() async {
        do {
            switch type {
            case .reply:
                notifications = try await appState.firstApi.getReplyNotifications(
                    page: 1,
                    cursor: nil,
                    limit: 5,
                    unreadOnly: false
                ).notifications
            case .mention:
                notifications = try await appState.firstApi.getMentionNotifications(
                    page: 1,
                    cursor: nil,
                    limit: 5,
                    unreadOnly: false
                ).notifications
            case .message:
                notifications = try await appState.firstApi.getMessageNotifications(
                    page: 1,
                    cursor: nil,
                    limit: 5,
                    unreadOnly: false
                ).notifications
            }
        } catch {
            handleError(error)
        }
    }
}
