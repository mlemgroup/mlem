//
//  CommentBodyView.swift
//  Mlem
//
//  Created by Sjmarf on 09/08/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommentBodyView: View {
    @Environment(\.exposeRemovedContent) var exposeRemovedContent
    
    @Setting(\.comment_compact) var compactComments
    
    let comment: any DeprecatedComment
    
    var body: some View {
        if comment.deleted {
            missingContentMessage("Comment was deleted")
        } else if comment.removed {
            if exposeRemovedContent {
                MarkdownWithLinkList(comment.content, configuration: .removedContent, showLinkCaptions: !compactComments)
            } else {
                missingContentMessage("Comment was removed")
            }
        } else {
            MarkdownWithLinkList(comment.content, showLinkCaptions: !compactComments)
        }
    }
    
    @ViewBuilder
    func missingContentMessage(_ label: LocalizedStringResource) -> some View {
        Text(label)
            .italic()
            .foregroundStyle(.themedSecondary)
    }
}
