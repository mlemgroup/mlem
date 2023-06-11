//
//  Subscribe Button.swift
//  Mlem
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

internal enum CommandError: Error
{
    case receivedUnexpectedResponseFromServer
}

struct SubscribeButton: View {
    @EnvironmentObject var appState: AppState
    
    @Binding var communityDetails: APICommunityView?
    
    @State var account: SavedAccount
    
    var body: some View {
        if let communityDetails {
            if communityDetails.subscribed == .notSubscribed
            {
                Button
                {
                    Task(priority: .userInitiated) {
                        print("Will subscribe")
                        await subscribe(communityId: communityDetails.community.id, shouldSubscribe: true)
                    }
                } label: {
                    Label("Subscribe", systemImage: "person.badge.plus")
                }

            }
            else
            {
                Button(role: .destructive)
                {
                    Task(priority: .userInitiated) {
                        print("Will unsubscribe")
                        await subscribe(communityId: communityDetails.community.id, shouldSubscribe: false)
                    }
                } label: {
                    Label("Unsubscribe", systemImage: "person.badge.minus")
                }
            }
        }
        else
        {
            Label("Loading community info…", systemImage: "clock.arrow.2.circlepath")
                .disabled(true)
        }
    }
    
    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        do {
            let request = FollowCommunityRequest(
                account: account,
                communityId: communityId,
                follow: shouldSubscribe
            )
            
            let response = try await APIClient().perform(request: request)
            self.communityDetails = response.communityView
        } catch {
            // TODO: If we fail here and want to notify the user we'd ideally
            // want to do so from the parent view, I think it would be worth refactoring
            // this view so that the responsibility for performing the call is removed
            // and handled by the parent, for now we will fail silently the UI state
            // will not update so will continue to be accurate
            print(error)
        }
    }
}
