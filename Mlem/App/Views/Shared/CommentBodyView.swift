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
    
    let comment: Comment
    
    var body: some View {
        Group {
            if comment.deleted {
                missingContentMessage("Comment was deleted")
            } else if comment.removed {
                if exposeRemovedContent {
                    TranslatableMarkdownView(markdown: comment.content, configuration: .removedContent, showLinkCaptions: !compactComments)
                } else {
                    missingContentMessage("Comment was removed")
                }
            } else {
                TranslatableMarkdownView(markdown: comment.content, showLinkCaptions: !compactComments)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    func missingContentMessage(_ label: LocalizedStringResource) -> some View {
        Text(label)
            .italic()
            .foregroundStyle(.themedSecondary)
    }
}
