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
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                ExpectedText(post.title)
                    .font(.headline)
                ExpectedMedia(url: post.linkUrl)
            
                Divider()
                
                HStack {
                    Button("Vote") {
                        Task {
                            do {
                                try await post.vote()
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                    Spacer()
                    Text("Vote: \(post.votes.value?.myVote ?? .none)")
                }
            }
            .padding(Constants.main.standardSpacing)
            .background(.themedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .padding(Constants.main.standardSpacing)
        }
        .background(.themedGroupedBackground)
    }
}
