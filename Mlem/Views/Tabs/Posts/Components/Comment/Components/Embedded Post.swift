//
//  Embedded Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-23.
//

import SwiftUI

struct EmbeddedPost: View {
    // environmnet
    @EnvironmentObject var postTracker: PostTracker
    
    let account: SavedAccount
    let community: APICommunity
    let post: APIPost

    @State var loadedPostDetails: APIPostView?

    // TODO:
    // - beautify
    // - enrich info
    // - navigation link to post
    var body: some View {
        NavigationLink(value: LazyLoadPostLinkWithContext(post: post, postTracker: postTracker)) {
            postLinkButton()
        }
    }
    
    @ViewBuilder
    private func postLinkButton() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(post.embedTitle ?? post.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .bold()
            HStack(alignment: .center, spacing: 0.0) {
                Text(community.name)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                
                if let serverHost = community.actorId.host() {
                    Text("@\(serverHost)")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .opacity(0.5)
                }
                Spacer()
            }
        }.padding(10)
        .background(RoundedRectangle(cornerRadius: 8)
        .foregroundColor(Color(UIColor.secondarySystemBackground)))
    }
}

struct EmbeddedPostPreview: PreviewProvider {
    static let previewAccount = SavedAccount(
        id: 0,
        instanceLink: URL(string: "lemmy.com")!,
        accessToken: "abcdefg",
        username: "Test Account"
    )
    
    static func generateFakeCommunity(id: Int, namePrefix: String) -> APICommunity {
        APICommunity(
            id: id,
            name: "\(namePrefix) Fake Community \(id)",
            title: "\(namePrefix) Fake Community \(id) Title",
            description: "This is a fake community (#\(id))",
            published: Date.now,
            updated: nil,
            removed: false,
            deleted: false,
            nsfw: false,
            actorId: URL(string: "https://lemmy.google.com/c/\(id)")!,
            local: false,
            icon: nil,
            banner: nil,
            hidden: false,
            postingRestrictedToMods: false,
            instanceId: 0
        )
    }
    
    static var previews: some View {
        EmbeddedPost(
            account: previewAccount,
            community: EmbeddedPostPreview.generateFakeCommunity(id: 1, namePrefix: ""),
            post: APIPost(
                id: 1,
                name: "Test Post",
                url: nil,
                body: nil,
                creatorId: 0,
                communityId: 0,
                deleted: false,
                embedDescription: nil,
                embedTitle: nil,
                embedVideoUrl: nil,
                featuredCommunity: false,
                featuredLocal: false,
                languageId: 0,
                apId: "foo.bar",
                local: false,
                locked: false,
                nsfw: false,
                published: Date.now,
                removed: false,
                thumbnailUrl: nil,
                updated: nil
            )
        )
    }
}
