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
            picker(tabs: InboxTab.personalCases, selected: $selectedPersonalTab)
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
                InboxFeedView(tracker: modOrAdminInboxTracker)
            case .commentReports:
                InboxFeedView(tracker: commentReportTracker)
            case .postReports:
                InboxFeedView(tracker: postReportTracker)
            case .messageReports:
                InboxFeedView(tracker: messageReportTracker)
            case .registrationApplications:
                InboxFeedView(tracker: registrationApplicationTracker)
            default:
                InboxFeedView(tracker: modOrAdminInboxTracker)
                    .onAppear {
                        assertionFailure("moderatorFeedView rendered with non-mod/admin tab!")
                    }
            }
        } header: {
            picker(tabs: siteInformation.isAdmin ? InboxTab.adminCases : InboxTab.modCases, selected: $selectedModTab)
        }
        .task {
            if modOrAdminInboxTracker.items.isEmpty {
                // wrap in subtask to view redraws don't cancel load
                Task(priority: .userInitiated) {
                    await refresh(tracker: modOrAdminInboxTracker)
                }
            }
        }
    }
}
