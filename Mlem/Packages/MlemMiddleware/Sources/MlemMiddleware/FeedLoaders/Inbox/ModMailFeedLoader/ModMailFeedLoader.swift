//
//  ModMailFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-27.
//

import Foundation

public class ModMailFeedLoader: StandardFeedLoader<ModMailItem> {
    
    var modMailFetcher: MultiFetcher<ModMailItem> { fetcher as! MultiFetcher }
    
    public init(
        api: ApiClient,
        pageSize: Int,
        sources: [ChildFeedLoader<ModMailItem>],
        sortType: FeedLoaderSort.SortType,
        showRead: Bool) {
            super.init(
                filter: ModMailItemFilter(showRead: showRead),
                fetcher: MultiFetcher(api: api, pageSize: pageSize, sources: sources, sortType: sortType)
            )
        
        sources.forEach { source in
            source.setParent(parent: self)
        }
    }
    
    public static func setup(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        showRead: Bool
    ) -> (
        reportFeedLoader: ReportChildFeedLoader,
        applicationFeedLoader: ApplicationChildFeedLoader,
        modMailFeedLoader: ModMailFeedLoader
    ) {
        let postReportFeedLoader: PostReportChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        let commentReportFeedLoader: CommentReportChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        let messageReportFeedLoader: MessageReportChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        
        let reportFeedLoader: ReportChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            sources: [postReportFeedLoader, commentReportFeedLoader, messageReportFeedLoader],
            showRead: showRead)
        
        let applicationFeedLoader: ApplicationChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            showRead: showRead
        )
        
        let modMailFeedLoader: ModMailFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sources: [reportFeedLoader, applicationFeedLoader],
            sortType: sortType,
            showRead: showRead
        )
        
        return (reportFeedLoader, applicationFeedLoader, modMailFeedLoader)
    }
    
    public func hideRead() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            modMailFetcher.sources.forEach { source in
                group.addTask {                    
                    guard let childSource = source as? any InboxFeedLoading else {
                        assertionFailure("Child is not ModMailChildFeedLoader")
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
            modMailFetcher.sources.forEach { source in
                group.addTask {
                    guard let childSource = source as? any InboxFeedLoading else {
                        assertionFailure("Child is not ModMailChildFeedLoader")
                        return
                    }
                    try await childSource.showRead()
                }
            }
        }

        try await deactivateFilter(.read)
    }
}
