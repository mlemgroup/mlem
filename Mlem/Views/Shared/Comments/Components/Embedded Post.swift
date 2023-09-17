//
//  Embedded Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-23.
//

import SwiftUI

struct EmbeddedPost: View {
    // used to handle the lazy load embedded post--speed doesn't matter because it's not a "real" post tracker
    @StateObject var postTracker: PostTracker
    
    let community: APICommunity
    let post: APIPost
    let comment: APIComment
    
    init(community: APICommunity, post: APIPost, comment: APIComment) {
        self.community = community
        self.post = post
        self.comment = comment
        
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        self._postTracker = StateObject(wrappedValue: .init(internetSpeed: .slow, upvoteOnSave: upvoteOnSave))
    }

    @State var loadedPostDetails: PostModel?

    // TODO:
    // - beautify
    // - enrich info
    // - navigation link to post
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(
            post: post,
            scrollTarget: comment.id
        ))) {
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
    static var previews: some View {
        EmbeddedPost(
            community: .mock(),
            post: .mock(),
            comment: .mock()
        )
    }
}
