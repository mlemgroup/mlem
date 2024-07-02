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
    @Environment(Palette.self) private var palette
    
    private let indent: CGFloat = 10
    
    let comment: any Comment1Providing
    
    var body: some View {
        let collapsed = (comment as? CommentWrapper)?.collapsed ?? false
        
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(entity: comment.creator_, labelStyle: .small, showAvatar: true)
                    Spacer()
                    if collapsed {
                        Image(systemName: Icons.expandComment)
                            .frame(height: 10)
                            .imageScale(.small)
                    } else {
                        EllipsisMenu(actions: comment.menuActions(), size: 10)
                    }
                }
                if !collapsed {
                    Markdown(comment.content, configuration: .default)
                    InteractionBarView(
                        comment: comment,
                        configuration: .init(
                            leading: [.counter(.score)],
                            trailing: [.action(.save), .action(.reply)],
                            readouts: [.created, .score, .comment]
                        )
                    )
                    .padding(.top, 2)
                }
            }
            .padding(.vertical, 2)
            .padding(AppConstants.standardSpacing)
            .clipped()
            .background(palette.background)
            .border(
                width: comment.depth == 0 ? 0 : 2, edges: [.leading],
                color: palette.commentIndentColors[comment.depth % palette.commentIndentColors.count]
            )
            .quickSwipes(comment.swipeActions(behavior: .standard))
            .contentShape(.rect)
            .onTapGesture {
                if let comment = comment as? CommentWrapper {
                    withAnimation {
                        comment.collapsed.toggle()
                    }
                }
            }
            .contextMenu(actionGroup: comment.menuActions(feedback: [.haptic]))
            Divider()
        }
        .padding(.leading, CGFloat(comment.depth) * indent)
    }
}
