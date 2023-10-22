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
    
    // parameters
    @State var community: CommunityModel

    @State private var selectionSection = 0
    var shouldShowCommunityHeaders: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        Section { view }
        .navigationTitle("Sidebar")
        .navigationBarTitleDisplayMode(.inline)
        .task(priority: .userInitiated) {
            // Load community details if they weren't provided already
            if community.moderators == nil {
                await loadCommunity()
            }
        }.refreshable {
            await loadCommunity()
        }
    }
    
    private func loadCommunity() async {
        do {
            errorMessage = nil
            let communityDetails: GetCommunityResponse = try await communityRepository.loadDetails(for: community.communityId)
            community = .init(from: communityDetails)
        } catch {
            errorMessage = "We were unable to load this community's details, please try again."
            errorHandler.handle(error)
        }
    }
    
    private func getRelativeTime(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date.now)
    }
    
    var view: some View {
        ScrollView {
            CommunitySidebarHeader(
                title: community.displayName,
                subtitle: "@\(community.name)@\(community.communityUrl.host()!)",
                avatarSubtext: .constant("Created \(getRelativeTime(date: community.creationDate))"),
                bannerURL: shouldShowCommunityHeaders ? community.banner : nil,
                avatarUrl: community.avatar,
                label1: "\(community.subscriberCount ?? 0) Subscribers",
                avatarType: .community
            )
            
            Picker(selection: $selectionSection, label: Text("Profile Section")) {
                Text("Description").tag(0)
                Text("Moderators").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if selectionSection == 0 {
                if let description = community.description {
                    MarkdownView(text: description, isNsfw: false).padding()
                }
            } else if selectionSection == 1 {
                VStack {
                    Divider()
                    if let moderators = community.moderators {
                        ForEach(moderators) { moderatorView in
                            
                            NavigationLink(.apiPerson(moderatorView.moderator)) {
                                HStack {
                                    UserLabelView(
                                        person: moderatorView.moderator,
                                        serverInstanceLocation: .bottom,
                                        overrideShowAvatar: true,
                                        communityContext: community
                                    )
                                    Spacer()
                                }.padding()
                            }
                            Divider()
                        }
                    }
                }.padding(.top)
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    func errorView(errorDetails: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: Icons.warning)
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
        icon: "https://vlemmy.net/pictrs/image/190f2d6a-ac38-448d-ae9b-f6d751eb6e69.png?format=webp",
        banner: "https://vlemmy.net/pictrs/image/719b61b3-8d8e-4aec-9f15-17be4a081f97.jpeg?format=webp"
    )
    
    static let previewUser: APIPerson = .mock(
        name: "ExamplePerson",
        displayName: "Example Person",
        actorId: URL(string: "lem.foo.bar/u/exampleperson")!
    )
    
    static let previewModerator = APICommunityModeratorView(community: previewCommunity, moderator: previewUser)
    
    static var previews: some View {
        let model = CommunityModel(from: GetCommunityResponse.mock(
            communityView: .mock(
                community: previewCommunity,
                subscribed: .subscribed
            ),
            moderators: .init(repeating: previewModerator, count: 11)
        ))
        
        CommunitySidebarView(community: model)
    }
}
