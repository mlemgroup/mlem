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
    @Setting(\.showPostCreator) private var showCreator
    @Setting(\.showPersonAvatar) private var showPersonAvatar
    @Setting(\.showCommunityAvatar) private var showCommunityAvatar
    
    @Environment(Palette.self) private var palette: Palette
    @Environment(ExpandedPostTracker.self) private var expandedPostTracker: ExpandedPostTracker?
    @Environment(\.communityContext) private var communityContext
    
    let post: any Post1Providing
    var isExpanded: Bool = false
    
    var body: some View {
        content
            .padding(Constants.main.standardSpacing)
            .background(palette.background)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
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
                    EllipsisMenu(size: 24) { post.menuActions(expandedPostTracker: expandedPostTracker) }
                }
            }
            
            LargePostBodyView(post: post, isExpanded: isExpanded)
            
            if showCreator || isExpanded, communityContext == nil {
                personLink
            }
            
            InteractionBarView(
                post: post,
                configuration: Settings.main.postInteractionBar,
                expandedPostTracker: expandedPostTracker,
                communityContext: communityContext
            )
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showPersonAvatar)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar)
    }
}
