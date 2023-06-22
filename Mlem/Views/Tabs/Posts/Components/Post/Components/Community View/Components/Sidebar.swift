//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI
import CachedAsyncImage

struct CommunitySidebarHeaderLabel : View {
    @State var text: String
    
    init(_ text: String) {
        self._text = State(initialValue: text)
    }
    
    var body: some View {
        Text(text).padding(3).foregroundColor(.white).background(RoundedRectangle(cornerRadius: 5).foregroundColor(.gray)).font(.footnote)
    }
}

struct CommunitySidebarHeaderAvatarView : View {
    @State var imageUrl: URL?
    
    var body: some View {
        ZStack {
            if let avatarURL = imageUrl {
                CachedAsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                        .overlay(Circle()
                        .stroke(.secondary, lineWidth: 2))
                } placeholder: {
                    ProgressView()
                }
            } else {
                // TODO: Default avatar?
                // TIL you cannot fill and stroke at the same time
                Circle().strokeBorder(.background, lineWidth: 2)
                    .background(Circle().fill(.secondary))
            }
        }
        .frame(width: 120, height: 120)
        .shadow(radius: 10)
        .background(Circle()
        .foregroundColor(.systemBackground))
    }
}

struct CommunitySidebarHeader : View {
    @State var communityDetails: GetCommunityResponse
    
    private func getRelativeTime(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date.now)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Banner
            VStack {
                if let bannerUrl = communityDetails.communityView.community.banner {
                    CachedAsyncImage(url: bannerUrl) { image in
                        image.centerCropped()
                    } placeholder: {
                        ProgressView()
                    }.frame(height: 200)
                }
            }
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 110)
                        CommunitySidebarHeaderAvatarView(imageUrl: communityDetails.communityView.community.icon)
                        
                        HStack {
                            Text("Created \(getRelativeTime(date: communityDetails.communityView.community.published))")
                        }.foregroundColor(.gray)
                        
                    }.padding([.leading])
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Spacer().frame(height: 170)
                        HStack {
                            CommunitySidebarHeaderLabel("\(communityDetails.communityView.counts.subscribers) Subscribers")
                            CommunitySidebarHeaderLabel("\(communityDetails.online) Online")
                        }
                        Spacer().frame(height: 20)
                        
                        Text(communityDetails.communityView.community.name).font(.title).bold().lineLimit(1)
                        Text("@\(communityDetails.communityView.community.name)@\(communityDetails.communityView.community.actorId.host()!)").font(.footnote).lineLimit(1)
                        
                    }.padding([.trailing])
                }
            }
        }
    }
}

struct CommunitySidebarView: View {

    @State var account: SavedAccount
    @Binding var communityDetails: GetCommunityResponse?
    @Binding var isActive: Bool
    
    @State private var selectionSection = 0

    var body: some View {
        Section {
            if let communityDetails {
                view(for: communityDetails)
            } else {
                ProgressView {
                    Text("Loading details…")
                }
            }
        }
        .navigationTitle("Sidebar")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            isActive = false
        }
    }
    
    @ViewBuilder
    private func view(for communityDetails: GetCommunityResponse) -> some View {
        ScrollView {
            CommunitySidebarHeader(communityDetails: communityDetails)
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
                    MarkdownView(text: description).padding()
                }
            }
            else if selectionSection == 1 {
                VStack {
                    Divider()
                    ForEach(communityDetails.moderators) { moderatorView in
                        
                        NavigationLink {
                            UserView(userID: moderatorView.moderator.id, account: account)
                        } label: {
                            HStack {
                                UserProfileLabel(account: account, user: moderatorView.moderator)
                                Spacer()
                            }.padding()
                        }
                        Divider()
                    }
                }.padding(.vertical)
            }
        }
    }
}

struct SidebarPreview: PreviewProvider {
    static let previewCommunityDescription: String = """
    This is an example community with some markdown:
    - Do not ~wear silly hats~ spam!
    - Ok maybe just a little bit.
    - I SAID **NO**!
    """
    
    static let previewCommunity = APICommunity(id: 0, name: "testcommunity", title: "Test Community", description: previewCommunityDescription, published: Date.now.advanced(by: -2000), updated: nil, removed: false, deleted: false, nsfw: false, actorId: URL(string: "https://lemmy.foo.com/c/testcommunity")!, local: false, icon: URL(string: "https://vlemmy.net/pictrs/image/190f2d6a-ac38-448d-ae9b-f6d751eb6e69.png?format=webp"), banner: URL(string:  "https://vlemmy.net/pictrs/image/719b61b3-8d8e-4aec-9f15-17be4a081f97.jpeg?format=webp") , hidden: false, postingRestrictedToMods: false, instanceId: 0)
    
    static let previewUser = APIPerson(id: 0, name: "ExamplePerson", displayName: "Example Person", avatar: nil, banned: false, published: "no", updated: nil, actorId: URL(string: "lem.foo.bar/u/exampleperson")!, bio: nil, local: false, banner: nil, deleted: false, inboxUrl: URL(string: "lem.foo.bar/u/exampleperson")!, sharedInboxUrl: nil, matrixUserId: nil, admin: false, botAccount: false, banExpires: nil, instanceId: 0)
    
    static let previewModerator = APICommunityModeratorView(community: previewCommunity, moderator: previewUser)
    
    static var previews: some View {
        CommunitySidebarView(account: SavedAccount(id: 0, instanceLink: URL(string: "https://lemmy.foo.com/")!, accessToken: "abcd", username: "foobar"), communityDetails: .constant( GetCommunityResponse(communityView: APICommunityView(community: previewCommunity, subscribed: .subscribed, blocked: false, counts: APICommunityAggregates(id: 0, communityId: 0, subscribers: 1234, posts: 0, comments: 0, published: Date.now, usersActiveDay: 0, usersActiveWeek: 0, usersActiveMonth: 0, usersActiveHalfYear: 0)), site: nil, moderators: [previewModerator, previewModerator, previewModerator, previewModerator, previewModerator, previewModerator, previewModerator, previewModerator, previewModerator, previewModerator, previewModerator], online: 23, discussionLanguages: [], defaultPostLanguage: nil)), isActive: .constant(true))
    }
}
