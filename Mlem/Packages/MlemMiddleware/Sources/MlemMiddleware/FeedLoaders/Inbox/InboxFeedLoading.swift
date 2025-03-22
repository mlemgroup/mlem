//
//  InboxFeedLoading.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-02-01.
//

protocol InboxFeedLoading: FeedLoading {
    func showRead() async throws
    func hideRead() async throws
}
