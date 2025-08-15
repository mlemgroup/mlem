//
//  TopCommunitiesListView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-15.
//

import MlemMiddleware
import SwiftUI

struct TopCommunitiesListView: View {
    @Environment(AppState.self) var appState
    
    @State var communityLoader: CommunityFeedLoader?

    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: 0) {
                if let communityLoader {
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
            }
            .animation(.easeOut(duration: 0.1), value: communityLoader?.items.isEmpty)
            .task {
                do {
                    communityLoader = .init(api: appState.firstApi)
                    try await communityLoader?.refresh(listing: .all)
                } catch {
                    handleError(error)
                }
            }
        }
        .background(.themedGroupedBackground)
        .navigationTitle("Communities")
    }
}
