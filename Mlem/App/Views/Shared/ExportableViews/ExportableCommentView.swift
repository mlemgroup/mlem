//
//  ExportableCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-26.
//

import SwiftUI
import MlemMiddleware

struct ExportableCommentView: View {
    
    let comment: any Comment1Providing
    let appState: AppState
    let showCreator: Bool
    let showStats: Bool
    
    let infoStackReadouts: [CommentBarConfiguration.ReadoutType] = [.upvote, .downvote, .created, .comment]
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showCreator)
        hasher.combine(showStats)
        return hasher.finalize()
    }
    
    var body: some View {
        content
            .background(.themedSecondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
            .padding(Constants.main.standardSpacing)
            .background(.themedGroupedBackground)
            .animation(.snappy, value: animationHashValue)
            .environment(appState)
            // .palette(colorPalette.palette)
            // .environment(\.colorScheme, colorScheme)
    }
    
    var content: some View {
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
}
