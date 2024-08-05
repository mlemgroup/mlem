//
//  LargePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct LargePostView: View {
    @AppStorage("post.showCreator") private var showCreator: Bool = false
    @AppStorage("user.showAvatar") private var showUserAvatar: Bool = true
    @AppStorage("community.showAvatar") private var showCommunityAvatar: Bool = true
    
    @Environment(Palette.self) private var palette: Palette
    @Environment(\.communityContext) private var communityContext
    
    let post: any Post1Providing
    var isExpanded: Bool = false
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
            .background(palette.background)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                if communityContext == nil {
                    communityLink
                } else {
                    personLink
                }
                
                Spacer()
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }
                
                if !isExpanded {
                    EllipsisMenu(actions: post.menuActions(), size: 24)
                }
            }
            
            LargePostBodyView(post: post, isExpanded: isExpanded)
            
            if showCreator || isExpanded, communityContext == nil {
                personLink
            }
            
            InteractionBarView(
                post: post,
                configuration: .init(
                    leading: [.counter(.score)],
                    trailing: [.action(.save), .action(.reply)],
                    readouts: [.created, .score, .comment]
                )
            )
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showUserAvatar)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar)
    }
}
