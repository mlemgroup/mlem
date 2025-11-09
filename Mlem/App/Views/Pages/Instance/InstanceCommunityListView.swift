//
//  InstanceCommunityListView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-09.
//  

import MlemMiddleware
import SwiftUI

struct InstanceCommunityListView: View {
    let communityLoader: CommunityFeedLoader

    var body: some View {
        LazyVStack(spacing: 0) {
            SearchResultsView(results: communityLoader.items) { community in
                CommunityListRow(
                    community,
                    readout: .subscribers,
                    visitContext: .other
                )
                .onAppear {
                    do {
                        try communityLoader.loadIfThreshold(community)
                    } catch {
                        handleError(error)
                    }
                }
            }
            EndOfFeedView(feedLoader: communityLoader, viewType: .hobbit)
        }
        .animation(.easeOut(duration: 0.1), value: communityLoader.items.isEmpty)
        .task { await refresh() }
    }

    func refresh() async {
        do {
            if communityLoader.loadingState == .initial {
                try await communityLoader.refresh(listing: .local)
            }
        } catch {
            handleError(error)
        }
    }
}
