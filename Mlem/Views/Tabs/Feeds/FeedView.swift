//
//  FeedView.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI

struct FeedView: View {
    let community: APICommunity?
    let feedType: FeedType
    @State var sortType: PostSortType
    var showLoading: Bool = false
    
    @EnvironmentObject var pinnedViewOptions: PinnedViewOptionsTracker
    
    var body: some View {
        FeedContentView(community: community, feedType: feedType, sortType: $sortType, showLoading: showLoading)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PostViewOptionsMenu(postSortType: $sortType)
                }
            }
    }
}
