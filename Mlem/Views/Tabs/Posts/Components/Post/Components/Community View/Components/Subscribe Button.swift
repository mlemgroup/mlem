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
    
    @Binding var community: Community?
    
    @State var account: SavedAccount
    
    var body: some View {
        if let communityDetails = community!.details
        {
            if !communityDetails.isSubscribed
            {
                Button
                {
                    Task(priority: .userInitiated) {
                        print("Will subscribe")
                        
                        community?.details?.isSubscribed.toggle()
                        
                        do
                        {
                            let subscribingCommandResult: String = try await sendPostCommand(account: account, endpoint: "community/follow", arguments: [
                                "community_id": community!.id,
                                "follow": true
                            ])
                            
                            print(subscribingCommandResult)
                            
                            if subscribingCommandResult.contains("\"error\"")
                            {
                                throw CommandError.receivedUnexpectedResponseFromServer
                            }
                        }
                        catch let subscribingError
                        {
                            
                            appState.alertType = .customError(title: "Could not subscribe to \(community!.name)", message: "Mlem received an unexpected response from the server")
                            
                            print("Failed while subscribing: \(subscribingError)")
                            
                            community?.details?.isSubscribed.toggle()
                        }
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
                        
                        community?.details?.isSubscribed.toggle()
                        
                        do
                        {
                            let unsubscribingCommandResult: String = try await sendPostCommand(account: account, endpoint: "community/follow", arguments: [
                                "community_id": community!.id,
                                "follow": false
                            ])
                            
                            print(unsubscribingCommandResult)
                            
                            if unsubscribingCommandResult.contains("\"error\"")
                            {
                                throw CommandError.receivedUnexpectedResponseFromServer
                            }
                        }
                        catch let unsubscribingError
                        {
                            appState.alertType = .customError(title: "Could not unsubscribe from \(community!.name)", message: "Mlem received an unexpected response from the server")
                            
                            print("Failed while unsubscribing: \(unsubscribingError)")
                            
                            community?.details?.isSubscribed.toggle()
                        }
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
}
