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
    @Setting(\.post_createImage_showCommunity) var postShowCommunity
    @Setting(\.post_createImage_showCreator) var postShowCreator
    @Setting(\.post_createImage_showStats) var postShowStats
    
    let comment: any Comment1Providing
    let post: any Post3Providing
    
    // Anything environment-dependent must be passed in because ImageRenderer doesn't work with @Environment
    let appState: AppState
    let colorScheme: ColorScheme
    
    let infoStackReadouts: [CommentBarConfiguration.ReadoutType] = [.upvote, .downvote, .created, .comment]
    let postInfoStackReadouts: [PostBarConfiguration.ReadoutType] = [.upvote, .downvote, .created, .comment]
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showPost)
        hasher.combine(showCreator)
        hasher.combine(showStats)
        hasher.combine(postShowCommunity)
        hasher.combine(postShowCreator)
        hasher.combine(postShowStats)
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
        VStack(spacing: -Constants.main.standardSpacing) {
            if showPost {
                ExportablePostView(
                    post: post,
                    appState: appState,
                    colorScheme: colorScheme
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            commentContent
                .geometryGroup()
        }
    }
    
    var commentContent: some View {
        HStack(spacing: 0) {
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
            .padding(.leading, showPost ? 11 : 0)
            .padding(Constants.main.standardSpacing)
        }
        .background(.themedSecondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .overlay(alignment: .leading) {
            // CommentBarView's maxHeight: .infinity sometimes causes scaling problems when the post is shown, putting
            // it in an overlay forces it to respect the correct parent scaling
            if showPost {
                CommentBarView(depth: 0)
                    .transition(.move(edge: .leading).combined(with: .scale))
            }
        }
        .padding(Constants.main.standardSpacing)
        .background(.themedGroupedBackground)
    }
}
