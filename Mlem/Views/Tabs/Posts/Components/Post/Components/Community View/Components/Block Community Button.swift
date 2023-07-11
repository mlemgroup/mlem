//
//  Block Community Button.swift
//  Mlem
//
//  Created by Jake Shirley on 6/30/23.
//

import SwiftUI

struct BlockCommunityButton: View {
    // environment
    @EnvironmentObject var appState: AppState

    // parameters
    @Binding var communityDetails: APICommunityView?

    var body: some View {
        if let communityDetails {
            if communityDetails.blocked {
                Button {
                    Task(priority: .userInitiated) {
                        await block(communityId: communityDetails.community.id, shouldBlock: false)
                    }
                } label: {
                    Label("Unblock", systemImage: "eye")
                }

            } else {
                Button(role: .destructive) {
                    Task(priority: .userInitiated) {
                        await block(communityId: communityDetails.community.id, shouldBlock: true)
                    }
                } label: {
                    Label("Block", systemImage: "eye.slash")
                }
            }
        } else {
            Label("Loading community info…", systemImage: "clock.arrow.2.circlepath")
                .disabled(true)
        }
    }
    
    private func block(communityId: Int, shouldBlock: Bool) async {
        do {
            let request = BlockCommunityRequest(
                account: appState.currentActiveAccount,
                communityId: communityId,
                block: shouldBlock
            )

            let response = try await APIClient().perform(request: request)
            self.communityDetails = response.communityView
        } catch {
            // TODO: If we fail here and want to notify the user we should
            // pass a message into the contextual error below
            appState.contextualError = .init(underlyingError: error)
        }
    }
}
