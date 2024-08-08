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
    var highlight: Bool = false
    var inFeed: Bool = false // flag to suppress threading/collapsing behavior
    
    var depth: Int { inFeed ? 0 : comment.depth }
    
    var body: some View {
        let collapsed = (comment as? CommentWrapper)?.collapsed ?? false
        
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLinkView(entity: comment.creator_, labelStyle: .small, showAvatar: true)
                    Spacer()
                    if collapsed {
                        Image(systemName: Icons.expandComment)
                            .frame(height: 10)
                            .imageScale(.small)
                    } else {
                        EllipsisMenu(size: 24) { comment.menuActions() }
                            .frame(height: 10)
                    }
                }
                if !collapsed {
                    if comment.deleted {
                        Text("Comment was deleted")
                            .italic()
                            .foregroundStyle(palette.secondary)
                    } else if comment.removed {
                        Text("Comment was removed")
                            .italic()
                            .foregroundStyle(palette.secondary)
                    } else {
                        Markdown(comment.content, configuration: .default)
                    }
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
            .padding(Constants.main.standardSpacing)
            .clipped()
            .background(highlight ? palette.accent.opacity(0.2) : .clear)
            .background(palette.background)
            .border(
                width: depth == 0 ? 0 : 2, edges: [.leading],
                color: palette.commentIndentColors[depth % palette.commentIndentColors.count]
            )
            .quickSwipes(comment.swipeActions(behavior: .standard))
            .contentShape(.rect)
            .onTapGesture {
                if !inFeed, let comment = comment as? CommentWrapper {
                    withAnimation {
                        comment.collapsed.toggle()
                    }
                }
            }
            .contextMenu { comment.menuActions() }
            Divider()
        }
        .padding(.leading, CGFloat(depth) * indent)
        .environment(\.commentContext, comment)
    }
}
