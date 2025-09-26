//
//  ExportablePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-09-24.
//

import SwiftUI
import MlemMiddleware

struct ExportablePostView: View {
    let post: any Post1Providing
    
    let infoStackReadouts: [PostBarConfiguration.ReadoutType] = [.upvote, .downvote, .created, .comment]
    
    var body: some View {
        content
            .background(.themedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .padding(Constants.main.standardSpacing)
            .background(.themedGroupedBackground)
            .environment(AppState.main)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    FullyQualifiedLabelView(post.community_, labelStyle: .medium)
                    
                    Spacer()
                    
                    if post.nsfw {
                        Image(icon: .lemmy.nsfwTag)
                            .foregroundStyle(.themedWarning)
                    }
                }
                
                LargePostBodyView(post: post, isPostPage: true, shouldBlur: false)
                
                FullyQualifiedLabelView(post.creator_, labelStyle: .medium)
                
                Divider()
                
                InfoStackView(readouts: infoStackReadouts.compactMap { post.readout(type: $0, showColor: false) })
            }
            .padding(Constants.main.standardSpacing)
        }
    }
}
