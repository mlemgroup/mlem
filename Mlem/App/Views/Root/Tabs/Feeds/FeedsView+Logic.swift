//
//  FeedsView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-27.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension PostGridView {
    var headerMenuActions: [BasicAction] {
        [
            .init(
                id: "subscribed",
                isOn: postFeedLoader.feedType.feedSelection != .subscribed,
                label: "Subscribed",
                color: .red,
                icon: Icons.subscribedFeed
            ) {
                Task {
                    do {
                        try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                    } catch {
                        handleError(error)
                    }
                }
            },
            .init(
                id: "local",
                isOn: postFeedLoader.feedType.feedSelection != .local,
                label: "Local",
                color: .purple,
                icon: Icons.localFeed
            ) {
                Task {
                    do {
                        try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .local))
                    } catch {
                        handleError(error)
                    }
                }
            },
            .init(
                id: "all",
                isOn: postFeedLoader.feedType.feedSelection != .all,
                label: "All",
                color: .blue,
                icon: Icons.federatedFeed
            ) {
                Task {
                    do {
                        try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .all))
                    } catch {
                        handleError(error)
                    }
                }
            }
        ]
    }
}
