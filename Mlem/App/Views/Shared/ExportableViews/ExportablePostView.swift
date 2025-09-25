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
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    communityLink
                    
                    Spacer()
                    
                    if post.nsfw {
                        Image(icon: .lemmy.nsfwTag)
                            .foregroundStyle(.themedWarning)
                    }
                }
                
                LargePostBodyView(post: post, isPostPage: false, shouldBlur: false)
                
                personLink
            }
            .padding([.top, .horizontal], Constants.main.standardSpacing)
            
            InteractionBarView(
                appState: AppState.main,
                post: post,
                configuration: interactionBarConfiguration,
                navigation: NavigationLayer()
            )
        }
    }
}
