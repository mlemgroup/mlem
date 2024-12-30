//
//  ModlogView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @Setting(\.showModlogWarning) var showModlogWarning
    
    let community: AnyCommunity?
    
    @State var feedLoader: ModlogFeedLoader
    
    @State var warningPresented: Bool = Settings.main.showModlogWarning
    
    init(community: AnyCommunity?) {
        self._feedLoader = .init(
            wrappedValue: .init(
                api: AppState.main.firstApi,
                pageSize: Settings.main.internetSpeed.pageSize,
                sortType: .new
            )
        )
        self.community = nil
    }
    
    var body: some View {
        Group {
            if let community {
                ContentLoader(model: community) { proxy in
                    content(community: proxy.entity)
                }
            } else {
                content(community: nil)
            }
        }
        .navigationTitle("Modlog")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $warningPresented) {
            WarningOverlayView(
                text: "The modlog may contain disturbing or adult material.",
                isPresented: $warningPresented,
                showWarningAgain: $showModlogWarning
            )
        }
    }
    
    @ViewBuilder
    func content(community: (any Community)?) -> some View {
        ScrollView {
            LazyVStack(spacing: Constants.main.standardSpacing) {
                ForEach(Array(feedLoader.items.enumerated()), id: \.offset) { _, entry in
                    ModlogEntryView(entry: entry, targetCommunity: community)
                        .onAppear {
                            do {
                                try feedLoader.loadIfThreshold(entry)
                            } catch {
                                handleError(error)
                            }
                        }
                }
                EndOfFeedView(loadingState: feedLoader.loadingState, loadMore: nil, viewType: .hobbit)
            }
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
        }
        .background(palette.groupedBackground)
        .loadFeed(feedLoader)
    }
}
