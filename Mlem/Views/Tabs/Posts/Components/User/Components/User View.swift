//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

/// View for showing user profiles
/// Accepts the following parameters:
/// - **userID**: Non-optional ID of the user
/// - **account**: Authenticated account to make the requests
/// - **userDetails**: Optional. If provided, uses already-available user details instead of fetching them from the view itself
struct UserView: View
{
    @EnvironmentObject var appState: AppState
    
    @State var userID: Int
    @State var account: SavedAccount
    
    @State var userDetails: User?
    @State private var userPosts: [Post]?
    @State private var userComments: [Comment]?

    var body: some View
    {
        ScrollView {
            if let userDetails
            {
                Text(userDetails.name)
            }
            else
            {
                ProgressView {
                    Text("Loading user details…")
                }
                .task(priority: .background) {
                    do
                    {
                        userDetails = try await loadUser()
                    }
                    catch let userRetrievalError as ConnectionError
                    {
                        switch userRetrievalError {
                            case .failedToEncodeAddress:
                                print("What")
                                
                            case .receivedInvalidResponseFormat:
                                appState.alertTitle = "Couldn't read user info"
                                appState.alertMessage = "Lemmy sent unexpected data"
                                appState.isShowingAlert = true
                                
                            case .failedToSendRequest:
                                appState.alertTitle = "Couldn't load user info"
                                appState.alertMessage = "There was an error while loading user information.\nTry again later."
                                appState.isShowingAlert = true
                        }
                    }
                    catch
                    {
                        print("What")
                    }
                }
            }
        }
    }
    
    func loadUser() async throws -> User
    {
        do
        {
            let userDetailsResponse: String = try await sendGetCommand(appState: appState, account: account, endpoint: "user", parameters: [
                URLQueryItem(name: "person_id", value: "\(userID)")
            ])
            
            do
            {
                return try await parseUser(userResponse: userDetailsResponse)
            }
            catch let userParsingError
            {
                print("Failed while parsing user info: \(userParsingError)")
                
                throw ConnectionError.receivedInvalidResponseFormat
            }
        }
        catch let userInfoRetrievalError
        {
            print("Failed while getting user info: \(userInfoRetrievalError)")
            
            throw ConnectionError.failedToSendRequest
        }
    }
}
