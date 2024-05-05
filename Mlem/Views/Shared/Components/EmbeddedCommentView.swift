//
//  EmbeddedCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-28.
//

import Foundation
import MarkdownUI
import SwiftUI

struct EmbeddedCommentView: View {
    let comment: APIComment
    let post: PostModel?
    let community: CommunityModel?
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(postId: comment.postId, scrollTarget: comment.id))) {
            content
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            if let post {
                Text(post.post.name)
                    .bold()
            }
            
            if let communityNameComponents = community?.fullyQualifiedNameComponents {
                HStack(alignment: .center, spacing: 0) {
                    Text("in \(communityNameComponents.0)")
                    Text("@\(communityNameComponents.1)").opacity(0.5)
                }
                .foregroundColor(.secondary)
                .font(.footnote)
            }
                
            MarkdownView(text: comment.content, isNsfw: false, isInline: true)
        }
        .padding(AppConstants.standardSpacing)
        .background {
            Rectangle()
                .foregroundColor(.secondarySystemBackground)
                .cornerRadius(AppConstants.standardSpacing)
        }
        .foregroundStyle(.secondary)
    }
}
