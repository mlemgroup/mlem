//
//  ReportChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-02-01.
//

class ReportFetcher: MultiFetcher<ModMailItem> {}

public class ReportChildFeedLoader: ChildFeedLoader<ModMailItem>, InboxFeedLoading {
    
    var reportFetcher: MultiFetcher<ModMailItem> { fetcher as! ReportFetcher }
    
    public init(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        sources: [ModMailChildFeedLoader],
        showRead: Bool
    ) {
        let fetcher: ReportFetcher = .init(
            api: api,
            pageSize: pageSize,
            sources: sources,
            sortType: sortType
        )
        
        super.init(filter: ModMailItemFilter(showRead: showRead), fetcher: fetcher, sortType: sortType)
        
        sources.forEach { source in
            source.setParent(parent: self)
        }
    }
    
    public func hideRead() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            reportFetcher.sources.forEach { source in
                group.addTask {
                    guard let childSource = source as? ModMailChildFeedLoader else {
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
            reportFetcher.sources.forEach { source in
                group.addTask {
                    guard let childSource = source as? ModMailChildFeedLoader else {
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
