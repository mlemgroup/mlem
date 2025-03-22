//
//  InboxFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-27.
//

import Foundation

public class InboxFeedLoader: StandardFeedLoader<InboxItem> {
    var inboxFetcher: MultiFetcher<InboxItem> { fetcher as! MultiFetcher }
    
    public init(api: ApiClient, pageSize: Int, sources: [ChildFeedLoader<InboxItem>], sortType: FeedLoaderSort.SortType, showRead: Bool) {
        super.init(filter: InboxItemFilter(showRead: showRead), fetcher: MultiFetcher(api: api, pageSize: pageSize, sources: sources, sortType: sortType))
        
        for source in sources {
            source.setParent(parent: self)
        }
    }
    
    public static func setup(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        showRead: Bool
    ) -> (
        replyFeedLoader: ReplyChildFeedLoader,
        mentionFeedLoader: MentionChildFeedLoader,
        messageFeedLoader: MessageChildFeedLoader,
        inboxFeedLoader: InboxFeedLoader
    ) {
        let replyFeedLoader: ReplyChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        let mentionFeedLoader: MentionChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        let messageFeedLoader: MessageChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        
        let inboxFeedLoader: InboxFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sources: [replyFeedLoader, mentionFeedLoader, messageFeedLoader],
            sortType: sortType,
            showRead: showRead
        )
        
        return (
            replyFeedLoader,
            mentionFeedLoader,
            messageFeedLoader,
            inboxFeedLoader
        )
    }
    
    public func hideRead() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            for source in inboxFetcher.sources {
                group.addTask {
                    guard let childSource = source as? InboxChildFeedLoader else {
                        assertionFailure("Child is not InboxChildFeedLoader")
                        return
                    }
                    try await childSource.hideRead()
                }
            }
        }
        
        try await activateFilter(.read)
    }
    
    public func showRead() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            for source in inboxFetcher.sources {
                group.addTask {
                    guard let childSource = source as? InboxChildFeedLoader else {
                        assertionFailure("Child is not InboxChildFeedLoader")
                        return
                    }
                    try await childSource.showRead()
                }
            }
        }

        try await deactivateFilter(.read)
    }
}
