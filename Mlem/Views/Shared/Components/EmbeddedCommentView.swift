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
    
    var body: some View {
        NavigationLink(.lazyLoadPostLinkWithContext(.init(postId: comment.postId, scrollTarget: comment.id))) {
            content
        }
    }
    
    var content: some View {
        MarkdownView(text: comment.content, isNsfw: false, foregroundColor: .secondary)
            .padding(AppConstants.standardSpacing)
            .background {
                Rectangle()
                    .foregroundColor(.secondarySystemBackground)
                    .cornerRadius(AppConstants.standardSpacing)
            }
    }
}
