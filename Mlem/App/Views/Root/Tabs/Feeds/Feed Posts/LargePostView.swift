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
    @Setting(\.blurNsfw) var blurNsfw
    
    @Environment(Palette.self) private var palette: Palette
    @Environment(ExpandedPostTracker.self) private var expandedPostTracker: ExpandedPostTracker?
    @Environment(\.communityContext) private var communityContext
    
    let post: any Post1Providing
    var isExpanded: Bool = false
    
    var shouldBlur: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var body: some View {
        content
            .padding(.vertical, 10)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: 10))
//            .background(palette.background)
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
            .padding(.horizontal, 10)
            
            LargePostBodyView(post: post, isExpanded: isExpanded, shouldBlur: shouldBlur)
                .padding(.horizontal, 10)
            
            if showCreator || isExpanded, communityContext == nil {
                personLink
                    .padding(.horizontal, 10)
            }
            
            if !(post.content?.isEmpty ?? true) {
                Divider()
                    .padding(.bottom, -10)
            }
            
            InteractionBarView(
                post: post,
                configuration: InteractionBarTracker.main.postInteractionBar,
                expandedPostTracker: expandedPostTracker,
                communityContext: communityContext
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showPersonAvatar, blurred: shouldBlur)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar, blurred: shouldBlur)
    }
}
