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
                InboxFeedView(tracker: personalInboxTracker)
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
        .task {
            if personalInboxTracker.items.isEmpty {
                // wrap in subtask to view redraws don't cancel load
                Task(priority: .userInitiated) {
                    await refresh(tracker: personalInboxTracker)
                }
            }
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
        .task {
            if modInboxTracker.items.isEmpty {
                // wrap in subtask to view redraws don't cancel load
                Task(priority: .userInitiated) {
                    await refresh(tracker: modInboxTracker)
                }
            }
        }
    }
    
    @ViewBuilder
    var adminFeedView: some View {
        Section {
            switch selectedModTab {
            case .all:
                InboxFeedView(tracker: adminInboxTracker)
            case .commentReports:
                InboxFeedView(tracker: commentReportTracker)
            case .postReports:
                InboxFeedView(tracker: postReportTracker)
            case .messageReports:
                Text("TODO")
            case .registrationApplications:
                Text("TODO")
            default:
                InboxFeedView(tracker: adminInboxTracker)
                    .onAppear {
                        assertionFailure("adminFeedView rendered with non-admin tab!")
                    }
            }
        } header: {
            BubblePicker(InboxTab.adminCases, selected: $selectedModTab, withDividers: [.bottom]) { tab in
                Text(tab.label)
            }
            .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
            .background(.bar)
            .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
        }
        .task {
            if modInboxTracker.items.isEmpty {
                // wrap in subtask to view redraws don't cancel load
                Task(priority: .userInitiated) {
                    await refresh(tracker: adminInboxTracker)
                }
            }
        }
    }
}
