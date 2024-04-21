//
//  InboxMessageReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxMessageReportView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var messageReport: MessageReportModel
    
    var body: some View {
        VStack(spacing: 0) {
            InboxMessageReportBodyView(messageReport: messageReport)
            InteractionBarView(context: .post, widgets: enrichLayoutWidgets())
        }
        .background(Color(uiColor: .systemBackground))
        .contentShape(Rectangle())
        .addSwipeyActions(
            messageReport.swipeActions(
                modToolTracker: modToolTracker,
                inboxTracker: modInboxTracker,
                unreadTracker: unreadTracker
            )
        )
        .contextMenu {
            ForEach(messageReport.genMenuFunctions(
                modToolTracker: modToolTracker,
                inboxTracker: modInboxTracker,
                unreadTracker: unreadTracker
            )) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        }
    }
    
    func toggleResolved() {
        Task {
            await messageReport.toggleResolved(unreadTracker: unreadTracker)
        }
    }
    
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.moderator.compactMap { baseWidget in
            switch baseWidget {
            case .resolve:
                return .resolve(resolved: messageReport.messageReport.resolved, resolve: toggleResolved)
            case .ban:
                return .ban(banned: messageReport.messageCreator.banned, instanceBan: true) {
                    messageReport.toggleMessageCreatorBanned(
                        modToolTracker: modToolTracker,
                        inboxTracker: modInboxTracker,
                        unreadTracker: unreadTracker
                    )
                }
            case .infoStack:
                return .spacer
            default:
                return nil
            }
        }
    }
}
