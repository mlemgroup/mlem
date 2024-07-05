//
//  FeedsView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-27.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension FeedsView {
    var headerMenuActions: [BasicAction] {
        switch postFeedLoader.feedType {
        case let .aggregateFeed(_, type):
            [
                .init(
                    id: "all",
                    isOn: type != .all,
                    label: "All",
                    color: palette.federatedFeed,
                    icon: type == .all ? Icons.federatedFeedFill : Icons.federatedFeed
                ) {
                    Task {
                        do {
                            try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .all))
                        } catch {
                            handleError(error)
                        }
                    }
                },
                .init(
                    id: "local",
                    isOn: type != .local,
                    label: "Local",
                    color: palette.localFeed,
                    icon: type == .local ? Icons.localFeedFill : Icons.localFeed
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
                    id: "subscribed",
                    isOn: type != .subscribed,
                    label: "Subscribed",
                    color: palette.subscribedFeed,
                    icon: type == .subscribed ? Icons.subscribedFeedFill : Icons.subscribedFeed
                ) {
                    Task {
                        do {
                            try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                        } catch {
                            handleError(error)
                        }
                    }
                }
            ]
        case .community:
            []
        }
    }
}
