//
//  CommentDraftRowView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-27.
//

import SwiftUI
import MlemMiddleware
import Dependencies

struct CommentDraftRowView: View {
    @Dependency(\.draftsTracker) var draftsTracker
    
    @Environment(AppState.self) var appState
    
    @State var draft: CommentDraft
    let active: Bool
    let inline: Bool
    var onDelete: (() -> Void)?
    
    var touchedText: String {
        if active {
            return "Just now"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: draft.touched, relativeTo: Date.now)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                authorAndTarget
                Spacer()
                delete
            }
            
            Text(draft.text)
                .lineLimit(1)
            
            Text(touchedText)
                .font(.footnote)
                .foregroundStyle(.themedSecondary)
        }
    }
    
    var authorAndTarget: some View {
        VStack(alignment: .leading) {
            if let author = draft.author {
                FullyQualifiedLabelView(author, labelStyle: .small)
                    .id(author.actorId) // otherwise the icon doesn't update
            }
            
            if !inline {
                if let post = draft.targetPost {
                    HStack(spacing: 0) {
                        Text("Post to ")
                        ExpectedView(post.community) { community in
                            FullyQualifiedLabelView(community, labelStyle: .small)
                        }
                    }
                } else if let comment = draft.targetComment {
                    HStack(spacing: 0) {
                        Text("Reply to ")
                        ExpectedView(comment.creator) { creator in
                            FullyQualifiedLabelView(creator, labelStyle: .small)
                        }
                    }
                }
            }
        }
    }
    
    var delete: some View {
        Button("Delete", icon: .general.delete, role: .destructive) {
            Task {
                do {
                    try await draftsTracker.deleteCommentDraft(draft.draftId)
                    onDelete?()
                } catch {
                    handleError(error)
                }
            }
        }
        .labelStyle(.iconOnly)
    }
}
