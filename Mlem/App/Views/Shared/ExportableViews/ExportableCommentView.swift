//
//  ExportableCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-26.
//

import SwiftUI
import MlemMiddleware

struct ExportableCommentView: View {
    @Setting(\.appearance_palette) var colorPalette
    @Setting(\.comment_createImage_showPost) var showPost: Bool
    @Setting(\.comment_createImage_showCreator) var showCreator: Bool
    @Setting(\.comment_createImage_showStats) var showStats: Bool
    
    let comment: any Comment1Providing
    
    // Anything environment-dependent must be passed in because ImageRenderer doesn't work with @Environment
    let appState: AppState
    let colorScheme: ColorScheme
    
    let infoStackReadouts: [CommentBarConfiguration.ReadoutType] = [.upvote, .downvote, .created, .comment]
    
    var shownPost: (any Post)? {
        if let comment2 = comment as? any Comment2Providing, showPost {
            return comment2.post
        }
        return nil
    }
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showPost)
        hasher.combine(showCreator)
        hasher.combine(showStats)
        return hasher.finalize()
    }
    
    var body: some View {
        content
            .animation(.snappy, value: animationHashValue)
            .environment(appState)
            .palette(colorPalette.palette)
            .environment(\.colorScheme, colorScheme)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            if let shownPost {
                ExportablePostView(
                    post: shownPost,
                    appState: appState,
                    colorScheme: colorScheme
                )
                .padding(.bottom, -10)
            }
            
            commentContent
        }
    }
    
    var commentContent: some View {
        HStack(spacing: 0) {
            if shownPost != nil {
                CommentBarView(depth: 0)
            }
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                if showCreator {
                    FullyQualifiedLabelView(comment.creator_, labelStyle: .medium, showFlairs: false)
                        .transition(.scale.combined(with: .opacity))
                }
                
                CommentBodyView(comment: comment)
                
                if showStats {
                    Divider()
                    InfoStackView(readouts: infoStackReadouts.compactMap { comment.readout(type: $0, showColor: false) })
                        .transition(.move(edge: .top).combined(with: .scale))
                }
            }
            .padding(Constants.main.standardSpacing)
        }
        .background(.themedSecondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .padding(Constants.main.standardSpacing)
        .background(.themedGroupedBackground)
    }
}
