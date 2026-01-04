//
//  DevPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-18.
//

import SwiftUI
import MlemMiddleware
import ComponentViews

struct DevPostView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.interactionBar_post) var interactionBarConfiguration
    
    @State var post: UnifiedPostModel
    
    init(post: any Post1Providing) {
        self.post = .init(api: post.api, url: post.url())
    }
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(post.title.value != nil ? 1 : 0)
        return hasher.finalize()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                    HStack {
                        ExpectedView(post.community) { community in
                            FullyQualifiedLinkView(community, labelStyle: .large)
                        } placeholder: {
                            Text("placeholder@placeholder")
                                .redacted(reason: .placeholder)
                        }
                        
                        Spacer()
                        
                        UnifiedPostEllipsisMenus(post: post)
                    }
                    
                    ExpectedText(post.title, expectedLength: 30)
                        .font(.headline)
                    ExpectedMedia(url: post.linkUrl)
                    
                    Divider()
                }
                .padding([.top, .leading, .trailing], Constants.main.standardSpacing)
                
                InteractionBarView(appState: appState, post: post, configuration: interactionBarConfiguration, navigation: navigation)
            }
            .background(.themedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .padding(Constants.main.standardSpacing)
        }
        .background(.themedGroupedBackground)
    }
}
