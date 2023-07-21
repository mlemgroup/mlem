//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct CommunitySidebarView: View {
    
    @EnvironmentObject var appState: AppState
    
    // parameters
    let community: APICommunity
    @State var communityDetails: GetCommunityResponse?

    @State private var selectionSection = 0
    var shouldShowCommunityHeaders: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        Section {
            if let shownError = errorMessage {
                errorView(errorDetials: shownError)
            } else if let loadedDetails = communityDetails {
                view(for: loadedDetails)
            } else {
                LoadingView(whatIsLoading: .communityDetails)
            }
        }
        .navigationTitle("Sidebar")
        .navigationBarTitleDisplayMode(.inline)
        .task(priority: .userInitiated) {
            // Load community details if they weren't provided
            // when we loaded
            if communityDetails == nil {
                await loadCommunity()
            }
        }.refreshable {
            await loadCommunity()
        }
    }
    
    private func loadCommunity() async {
        do {
            let request = GetCommunityRequest(account: appState.currentActiveAccount, communityId: community.id)
            communityDetails = try await APIClient().perform(request: request)
        } catch APIClientError.networking {
            errorMessage = "Network error occurred, check your internet and retry"
        } catch APIClientError.response {
            errorMessage = "API error occurred, try refreshing"
        } catch APIClientError.cancelled {
            errorMessage = "Request was cancelled, try refreshing"
        } catch {
            errorMessage = "A decoding error occurred, try refreshing."
        }
    }
    
    private func getRelativeTime(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date.now)
    }
    
    @ViewBuilder
    private func view(for communityDetails: GetCommunityResponse) -> some View {
        ScrollView {
            CommunitySidebarHeader(
                title: communityDetails.communityView.community.name,
                subtitle: "@\(communityDetails.communityView.community.name)@\(communityDetails.communityView.community.actorId.host()!)",
                avatarSubtext: .constant("Created \(getRelativeTime(date: communityDetails.communityView.community.published))"),
                bannerURL: shouldShowCommunityHeaders ? communityDetails.communityView.community.banner : nil,
                avatarUrl: communityDetails.communityView.community.icon,
            label1: "\(communityDetails.communityView.counts.subscribers) Subscribers")
            
            Picker(selection: $selectionSection, label: Text("Profile Section")) {
                Text("Description").tag(0)
                Text("Moderators").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if selectionSection == 0 {
                if let description = communityDetails
                    .communityView
                    .community
                    .description {
                    MarkdownView(text: description, isNsfw: false).padding()
                }
            } else if selectionSection == 1 {
                VStack {
                    Divider()
                    ForEach(communityDetails.moderators) { moderatorView in

                        NavigationLink(value: moderatorView.moderator) {
                            HStack {
                                UserProfileLabel(
                                    user: moderatorView.moderator,
                                    serverInstanceLocation: .bottom,
                                    overrideShowAvatar: true,
                                    communityContext: communityDetails
                                )
                                Spacer()
                            }.padding()
                        }
                        Divider()
                    }
                }.padding(.vertical)
            }
        }
    }
    
    @ViewBuilder
    func errorView(errorDetials: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.bubble")
                .font(.title)
            
            Text("Community details loading failed!")
            Text(errorDetials)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .accessibilityElement(children: .combine)
        .padding()
    }
}

struct SidebarPreview: PreviewProvider {
    static let previewCommunityDescription: String = """
    This is an example community with some markdown:
    - Do not ~wear silly hats~ spam!
    - Ok maybe just a little bit.
    - I SAID **NO**!
    """
    
    static let previewCommunity = APICommunity(
        id: 0,
        name: "testcommunity",
        title: "Test Community",
        description: previewCommunityDescription,
        published: Date.now.advanced(by: -2000),
        updated: nil,
        removed: false,
        deleted: false,
        nsfw: false,
        actorId: URL(string: "https://lemmy.foo.com/c/testcommunity")!,
        local: false,
        icon: URL(string: "https://vlemmy.net/pictrs/image/190f2d6a-ac38-448d-ae9b-f6d751eb6e69.png?format=webp"),
        banner: URL(string: "https://vlemmy.net/pictrs/image/719b61b3-8d8e-4aec-9f15-17be4a081f97.jpeg?format=webp"),
        hidden: false,
        postingRestrictedToMods: false,
        instanceId: 0
    )
    
    static let previewUser = APIPerson(
        id: 0,
        name: "ExamplePerson",
        displayName: "Example Person",
        avatar: nil,
        banned: false,
        published: Date.now,
        updated: nil,
        actorId: URL(string: "lem.foo.bar/u/exampleperson")!,
        bio: nil,
        local: false,
        banner: nil,
        deleted: false,
        sharedInboxUrl: nil,
        matrixUserId: nil,
        admin: false,
        botAccount: false,
        banExpires: nil,
        instanceId: 0
    )

    static let previewModerator = APICommunityModeratorView(community: previewCommunity, moderator: previewUser)
    
    static var previews: some View {
        CommunitySidebarView(
            community: previewCommunity,
            communityDetails:
                GetCommunityResponse(
                    communityView: APICommunityView(
                        community: previewCommunity,
                        subscribed: .subscribed,
                        blocked: false,
                        counts: APICommunityAggregates(
                            id: 0,
                            communityId: 0,
                            subscribers: 1234,
                            posts: 0,
                            comments: 0,
                            published: Date.now,
                            usersActiveDay: 0,
                            usersActiveWeek: 0,
                            usersActiveMonth: 0,
                            usersActiveHalfYear: 0
                        )
                    ),
                    site: nil,
                    moderators: .init(repeating: previewModerator, count: 11),
                    discussionLanguages: [],
                    defaultPostLanguage: nil
                )
        )
    }
}
