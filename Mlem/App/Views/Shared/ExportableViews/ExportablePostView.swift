//
//  ExportablePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-09-24.
//

import MlemMiddleware
import SwiftUI

struct ExportablePostView: View {
    @Setting(\.appearance_palette) var colorPalette
    
    let post: any Post1Providing
    let appState: AppState // directly passed in because ImageRenderer doesn't work with @Environment
    let colorScheme: ColorScheme
    let showCommunity: Bool
    let showCreator: Bool
    let showStats: Bool
    
    let infoStackReadouts: [PostBarConfiguration.ReadoutType] = [.upvote, .downvote, .created, .comment]
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showCommunity)
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
            .palette(colorPalette.palette)
            .environment(\.colorScheme, colorScheme)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            if showCommunity {
                FullyQualifiedLabelView(post.community_, labelStyle: .medium, showFlairs: false)
                    .transition(.scale.combined(with: .opacity))
            }
            
            LargePostBodyView(post: post, isPostPage: true, shouldBlur: false)
            
            if showCreator {
                FullyQualifiedLabelView(post.creator_, labelStyle: .medium, showFlairs: false)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if showStats {
                Divider()
                
                InfoStackView(readouts: infoStackReadouts.compactMap { post.readout(type: $0, showColor: false) })
                    .transition(.move(edge: .top).combined(with: .scale))
            }
        }
        .padding(Constants.main.standardSpacing)
    }
}
