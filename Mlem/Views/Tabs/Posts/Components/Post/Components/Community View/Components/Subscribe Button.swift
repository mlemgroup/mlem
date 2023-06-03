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
    
    @Binding var community: Community?
    
    @State var account: SavedAccount
    
    @State private var isShowingSubscribingAlert: Bool = true
    @State private var isShowingUnsubscribingAlert: Bool = false
    
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
                            let subscribingCommandResult: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
                            {"op": "FollowCommunity", "data": { "auth": "\(account.accessToken)", "community_id": \(community!.id), "follow": true }}
                            """)
                            
                            print(subscribingCommandResult)
                            
                            if subscribingCommandResult.contains("\"error\"")
                            {
                                throw CommandError.receivedUnexpectedResponseFromServer
                            }
                        }
                        catch let subscribingError
                        {
                            print("Failed while subscribing: \(subscribingError)")
                            isShowingSubscribingAlert.toggle()
                            
                            community?.details?.isSubscribed.toggle()
                        }
                    }
                } label: {
                    Label("Subscribe", systemImage: "person.badge.plus")
                }
                .alert("Could not subscribe to \(community!.name)", isPresented: $isShowingSubscribingAlert) {
                    Button(role: .cancel) {
                        isShowingSubscribingAlert.toggle()
                    } label: {
                        Text("Close")
                    }
                } message: {
                    Text("Mlem received an unexpected response from the server")
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
                            let unsubscribingCommandResult: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
                            {"op": "FollowCommunity", "data": { "auth": "\(account.accessToken)", "community_id": \(community!.id), "follow": false }}
                            """)
                            
                            print(unsubscribingCommandResult)
                            
                            if unsubscribingCommandResult.contains("\"error\"")
                            {
                                throw CommandError.receivedUnexpectedResponseFromServer
                            }
                        }
                        catch let unsubscribingError
                        {
                            print("Failed while unsubscribing: \(unsubscribingError)")
                            isShowingUnsubscribingAlert.toggle()
                            
                            community?.details?.isSubscribed.toggle()
                        }
                    }
                } label: {
                    Label("Unsubscribe", systemImage: "person.badge.minus")
                }
                .alert("Could not unsubscribe from \(community!.name)", isPresented: $isShowingUnsubscribingAlert) {
                    Button(role: .cancel) {
                        isShowingUnsubscribingAlert.toggle()
                    } label: {
                        Text("Close")
                    }
                } message: {
                    Text("Mlem received an unexpected response from the server")
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
