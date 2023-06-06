//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import CachedAsyncImage
import SwiftUI

/// View for showing user profiles
/// Accepts the following parameters:
/// - **userID**: Non-optional ID of the user
/// - **account**: Authenticated account to make the requests
struct UserView: View
{
    @EnvironmentObject var appState: AppState

    @State var userID: Int
    @State var account: SavedAccount

    @State private var userDetailsResponse: String = ""
    
    @State var userDetails: User?

    @State private var imageHeader: Image?
    
    @StateObject var privatePostTracker: PostTracker = .init()
    @StateObject var privateCommentTracker: CommentTracker = .init()

    var body: some View
    {
        NavigationStack
        {
            if let userDetails
            {
                List
                {
                    Section
                    {
                        VStack(alignment: .center, spacing: 15)
                        {
                            if let avatarURL = userDetails.avatarLink
                            {
                                CachedAsyncImage(url: avatarURL)
                                { image in
                                    image
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            if let bio = userDetails.bio
                            {
                                MarkdownView(text: bio)
                            }

                            HStack(alignment: .center, spacing: 20)
                            {
                                VStack(alignment: .center, spacing: 2)
                                {
                                    Text(String(userDetails.details!.commentScore))
                                        .fontWeight(.bold)
                                    Text("Comment\nScore")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }

                                VStack(alignment: .center, spacing: 2)
                                {
                                    Text(String(userDetails.details!.postScore))
                                        .fontWeight(.bold)
                                    Text("Post\nScore")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)

                    #warning("TODO: Make showing a user's posts and comments work")
                    /*
                    Section
                    {
                        NavigationLink {
                            ScrollView
                            {
                                LazyVStack {
                                    ForEach(privatePostTracker.posts)
                                    { post in
                                        NavigationLink {
                                            PostExpanded(account: account, postTracker: privatePostTracker, post: post, feedType: .constant(.subscribed))
                                        } label: {
                                            PostItem(postTracker: privatePostTracker, post: post, isExpanded: false, isInSpecificCommunity: false, account: account, feedType: .constant(.subscribed))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .navigationTitle("Recents by \(userDetails.name)")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Text("Recent Posts")
                        }

                    }
                     */
                }
                .navigationTitle(userDetails.name)
                .navigationBarTitleDisplayMode(.inline)
                .headerProminence(.standard)
            }
            else
            {
                ProgressView
                {
                    Text("Loading user details…")
                }
                .task(priority: .background)
                {
                    do
                    {
                        userDetails = try await loadUser()
                        
                        privateCommentTracker.comments = try await parseComments(commentResponse: userDetailsResponse, instanceLink: account.instanceLink)
                        privatePostTracker.posts = try await parsePosts(postResponse: userDetailsResponse, instanceLink: account.instanceLink)
                    }
                    catch let userRetrievalError as ConnectionError
                    {
                        switch userRetrievalError
                        {
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
            userDetailsResponse = try await sendGetCommand(appState: appState, account: account, endpoint: "user", parameters: [
                URLQueryItem(name: "person_id", value: "\(userID)"),
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
