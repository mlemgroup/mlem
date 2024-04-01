//
//  InboxView+Feeds.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-01.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    var allFeedView: some View {
        Section {
            switch selectedInboxTab {
            case .all:
                switch selectedInbox {
                case .all:
                    InboxFeedView(tracker: inboxTracker)
                case .personal:
                    InboxFeedView(tracker: personalInboxTracker)
                case .mod:
                    InboxFeedView(tracker: modInboxTracker)
                }
            case .replies:
                InboxFeedView(tracker: replyTracker)
            case .mentions:
                InboxFeedView(tracker: mentionTracker)
            case .messages:
                InboxFeedView(tracker: messageTracker)
            case .commentReports:
                InboxFeedView(tracker: commentReportTracker)
            default:
                Text("TODO")
            }
        } header: {
            BubblePicker(InboxTab.allCases, selected: $selectedInboxTab, withDividers: [.bottom]) { tab in
                Text(tab.label)
            }
            .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
            .background(.bar)
            .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
        }
    }
    
    @ViewBuilder
    var personalFeedView: some View {
        Section {
            switch selectedPersonalTab {
            case .all:
                InboxFeedView(tracker: personalInboxTracker)
            case .replies:
                InboxFeedView(tracker: replyTracker)
            case .mentions:
                InboxFeedView(tracker: mentionTracker)
            case .messages:
                InboxFeedView(tracker: messageTracker)
            default:
                InboxFeedView(tracker: inboxTracker)
                    .onAppear {
                        assertionFailure("personalFeedView rendered with non-personal tab!")
                    }
            }
        } header: {
            BubblePicker(InboxTab.personalCases, selected: $selectedPersonalTab, withDividers: [.bottom]) { tab in
                Text(tab.label)
            }
            .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
            .background(.bar)
            .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
        }
    }
    
    @ViewBuilder
    var moderatorFeedView: some View {
        Section {
            switch selectedModTab {
            case .all:
                InboxFeedView(tracker: modInboxTracker)
            case .commentReports:
                InboxFeedView(tracker: commentReportTracker)
            case .postReports:
                Text("TODO")
            case .messageReports:
                Text("TODO")
            default:
                InboxFeedView(tracker: modInboxTracker)
                    .onAppear {
                        assertionFailure("moderatorFeedView rendered with non-moderator tab!")
                    }
            }
        } header: {
            BubblePicker(InboxTab.modCases, selected: $selectedModTab, withDividers: [.bottom]) { tab in
                Text(tab.label)
            }
            .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
            .background(.bar)
            .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
        }
    }
}
