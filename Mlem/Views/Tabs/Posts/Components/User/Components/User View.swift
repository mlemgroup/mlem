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
struct UserView: View {
    @EnvironmentObject var appState: AppState

    @State var userID: Int
    @State var account: SavedAccount
    
    @State var userDetails: APIPersonView?

    @State private var imageHeader: Image?
    
    @StateObject var privatePostTracker: PostTracker = .init()
    @StateObject var privateCommentTracker: CommentTracker = .init()
    
    @State private var errorAlert: ErrorAlert?

    var body: some View {
        NavigationStack {
            contentView
                .alert(using: $errorAlert) { content in
                    Alert(title: Text(content.title), message: Text(content.message))
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let userDetails {
            view(for: userDetails)
        } else {
            progressView
        }
    }
    
    private func view(for userDetails: APIPersonView) -> some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 15) {
                    if let avatarURL = userDetails.person.avatar {
                        CachedAsyncImage(url: avatarURL) { image in
                            image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    if let bio = userDetails.person.bio {
                        MarkdownView(text: bio)
                    }
                    
                    HStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .center, spacing: 2) {
                            Text(String(userDetails.counts.commentScore))
                                .fontWeight(.bold)
                            Text("Comment\nScore")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text(String(userDetails.counts.postScore))
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
        .navigationTitle(userDetails.person.name)
        .navigationBarTitleDisplayMode(.inline)
        .headerProminence(.standard)
    }
    
    private var progressView: some View {
        ProgressView {
            Text("Loading user details…")
        }
        .task(priority: .background) {
            do {
                let response = try await loadUser()
                
                userDetails = response.personView
                privateCommentTracker.comments = response.comments.hierarchicalRepresentation
                privatePostTracker.posts = response.posts
            } catch {
                handle(error)
            }
        }
    }
    
    private func loadUser() async throws -> GetPersonDetailsResponse {
        let request = try GetPersonDetailsRequest(
            accessToken: account.accessToken,
            instanceURL: account.instanceLink,
            personId: userID
        )
        
        return try await APIClient().perform(request: request)
    }
    
    private func handle(_ error: Error) {
        switch error {
        case APIClientError.response(let message, _):
            errorAlert = .init(
                title: "Error",
                message: message.error
            )
        case is APIClientError:
            errorAlert = .init(
                title: "Couldn't load user info",
                message: "There was an error while loading user information.\nTry again later."
            )
        default:
            errorAlert = .unexpected
        }
    }
}
