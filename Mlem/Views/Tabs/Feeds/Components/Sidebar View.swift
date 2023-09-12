//
//  Sidebar View.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import Dependencies
import SwiftUI

struct CommunitySidebarView: View {
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.dismiss) private var dismiss
    
    // parameters
    let community: APICommunity
    @State var communityDetails: GetCommunityResponse?

    @State private var selectionSection = 0
    var shouldShowCommunityHeaders: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        Section {
            if let loadedDetails = communityDetails {
                view(for: loadedDetails)
            } else if let shownError = errorMessage {
                errorView(errorDetails: shownError)
            } else {
                LoadingView(whatIsLoading: .communityDetails)
            }
        }
        .navigationTitle("Sidebar")
        .navigationBarTitleDisplayMode(.inline)
        .hoistNavigation(dismiss: dismiss)
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
            errorMessage = nil
            communityDetails = try await communityRepository.loadDetails(for: community.id)
        } catch {
            errorMessage = "We were unable to load this communities details, please try again."
            errorHandler.handle(error)
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
                label1: "\(communityDetails.communityView.counts.subscribers) Subscribers"
            )
            
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

                        NavigationLink(.apiPerson(moderatorView.moderator)) {
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
                }.padding(.top)
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    func errorView(errorDetails: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.bubble")
                .font(.title)
            
            Text("Community details loading failed!")
            Text(errorDetails)
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
    
    static let previewCommunity: APICommunity = .mock(
        name: "testcommunity",
        title: "Test Community",
        description: previewCommunityDescription,
        actorId: URL(string: "https://lemmy.foo.com/c/testcommunity")!,
        icon: URL(string: "https://vlemmy.net/pictrs/image/190f2d6a-ac38-448d-ae9b-f6d751eb6e69.png?format=webp"),
        banner: URL(string: "https://vlemmy.net/pictrs/image/719b61b3-8d8e-4aec-9f15-17be4a081f97.jpeg?format=webp")
    )
    
    static let previewUser: APIPerson = .mock(
        name: "ExamplePerson",
        displayName: "Example Person",
        actorId: URL(string: "lem.foo.bar/u/exampleperson")!
    )
    
    static let previewModerator = APICommunityModeratorView(community: previewCommunity, moderator: previewUser)
    
    static var previews: some View {
        CommunitySidebarView(
            community: previewCommunity,
            communityDetails: .mock(
                communityView: .mock(
                    community: previewCommunity,
                    subscribed: .subscribed
                ),
                moderators: .init(repeating: previewModerator, count: 11)
            )
        )
    }
}
