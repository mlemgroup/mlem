//
//  CommentView.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommentView: View {
    private let threadingColors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    private let indent: CGFloat = 10
    
    let comment: any Comment1Providing
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(entity: comment.creator_, labelStyle: .small, showAvatar: true)
                Spacer()
                EllipsisMenu(actions: comment.menuActions, size: 24)
            }
            Markdown(comment.content, configuration: .default)
            InteractionBarView(
                comment: comment,
                configuration: .init(
                    leading: [.counter(.score)],
                    trailing: [.action(.save)],
                    readouts: [.created, .score, .comment]
                )
            )
            .padding(.vertical, 2)
        }
        .padding(AppConstants.standardSpacing)
        .border(width: comment.depth == 0 ? 0 : 2, edges: [.leading], color: threadingColors[comment.depth % threadingColors.count])
        .padding(.leading, CGFloat(comment.depth) * indent)
    }
}
