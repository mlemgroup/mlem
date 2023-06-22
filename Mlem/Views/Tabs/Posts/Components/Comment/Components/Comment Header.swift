//
//  Comment Header.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct CommentHeader: View {
    let commentView: APICommentView
    let account: SavedAccount
    
    // computed
    var publishedAgo: String { getTimeIntervalFromNow(date: commentView.post.published )}
    
    var body: some View {
                HStack() {
                    UserProfileLink(account: account, user: commentView.creator)
        
                    Spacer()
        
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                        Text(publishedAgo)
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
    }
}
