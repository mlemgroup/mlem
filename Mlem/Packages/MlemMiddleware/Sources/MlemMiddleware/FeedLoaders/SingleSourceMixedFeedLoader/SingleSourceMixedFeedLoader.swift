//
//  SingleSourceMixedFeedLoader.swift
//
//
//  Created by Eric Andrews on 2024-07-09.
//

import Foundation
import Nuke
import Semaphore

/// This is a special type of FeedLoader built for user content, which is uniquely challenging because you cannot load
/// just posts or just comments, and thus the standard Parent/Child FeedLoader construction does not work without
/// severe API waste. This solution is a simplified variant of that architecture.
///
/// The SingleSourceMixedFeedLoader is the parent loader. It is responsible for all data fetching, and keeps track of two
/// PersonContentStreams, one for Posts and one for Comments. To load a page of items, it consumes and merges the child streams, just as
/// in the standard Parent/Child FeedLoader; if either stream reaches the end of its items, it triggers a new load, the response from
/// which is then incorporated into both child streams.

@Observable
class SingleSourceMixedFetcher: Fetcher<PersonContent> {
    var sortType: FeedLoaderSort.SortType
    var userId: Int
    var savedOnly: Bool
    
    var postStream: PersonContentStream<Post>
    var commentStream: PersonContentStream<Comment>
    
    init(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        userId: Int,
        savedOnly: Bool,
        prefetchingConfiguration: PrefetchingConfiguration
    ) {
        self.sortType = sortType
        self.userId = userId
        self.savedOnly = savedOnly
        self.postStream = .init(items: [], prefetchingConfiguration: prefetchingConfiguration)
        self.commentStream = .init(items: [], prefetchingConfiguration: prefetchingConfiguration)
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func reset() async {
        postStream.reset()
        commentStream.reset()
        
        await super.reset()
    }
    
    override func fetch() async throws -> LoadingResponse<PersonContent> {
        var newItems: [PersonContent] = .init()
        
        while newItems.count < pageSize {
            if let nextItem = try await computeNextItem() {
                newItems.append(nextItem)
            } else {
                return .done(newItems)
            }
        }
        
        return .success(newItems)
    }
    
    override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<PersonContent> {
        fatalError("Unsupported loading operation")
    }
    
    /// Returns the next post or comment, depending on which is sorted first
    private func computeNextItem() async throws -> PersonContent? {
        // if either postStream or commentStream needs items, load the next page from the API
        if postStream.needsMoreItems || commentStream.needsMoreItems, let cursor = self.location.cursor {
            let response = try await api.getContent(
                authorId: userId,
                sort: .new,
                pageInfo: .init(cursor: cursor, limit: pageSize),
                savedOnly: savedOnly
            )
            postStream.addItems(response.posts)
            commentStream.addItems(response.comments)
            self.location = response.nextLocation
        }
        
        let nextPost = try await postStream.nextItemSortVal(sortType: sortType)
        let nextComment = try await commentStream.nextItemSortVal(sortType: sortType)
        
        if let nextPost {
            if let nextComment {
                // if both next post and next comment, return higher sort
                return nextPost > nextComment ? postStream.consumeNextItem() : commentStream.consumeNextItem()
            } else {
                // if next post but no next comment, return next post
                return postStream.consumeNextItem()
            }
        }
        
        // if no next post, always return next comment (this returns nil if no next comment)
        return commentStream.consumeNextItem()
    }
}

public class SingleSourceMixedFeedLoader: StandardFeedLoader<PersonContent> {
    // force unwrap because this should ALWAYS be a SingleSourceMixedFetcher
    var singleSourceMixedFetcher: SingleSourceMixedFetcher { fetcher as! SingleSourceMixedFetcher }
    
    public var api: ApiClient { singleSourceMixedFetcher.api }
    public var userId: Int { singleSourceMixedFetcher.userId }
    
    // MARK: Custom Behavior

    // This FeedLoader is slightly awkward because it functions like a multi-loader but draws its posts and comments from a single API call. The streams act essentially like child loaders, but are populated using custom behavior in the fetcher. This FeedLoader is best understood as a multi-loader with the streams as child loaders.
    
    private var postStream: PersonContentStream<Post> { singleSourceMixedFetcher.postStream }
    private var commentStream: PersonContentStream<Comment> { singleSourceMixedFetcher.commentStream }
    
    // these are used to allow refresh without clear
    private var tempPostStream: PersonContentStream<Post>?
    private var tempCommentStream: PersonContentStream<Comment>?
    
    // convenience accessors for child types
    public var posts: [PersonContent] { tempPostStream?.items ?? postStream.items }
    public var postLoadingState: FeedLoadingState { postStream.doneLoading ? .done : loadingState }
    
    public var comments: [PersonContent] { tempCommentStream?.items ?? commentStream.items }
    public var commentLoadingState: FeedLoadingState { commentStream.doneLoading ? .done : loadingState }
    
    public init(
        api: ApiClient,
        pageSize: Int,
        userId: Int,
        sortType: FeedLoaderSort.SortType,
        savedOnly: Bool,
        prefetchingConfiguration: PrefetchingConfiguration
    ) {
        super.init(filter: MultiFilter(), fetcher: SingleSourceMixedFetcher(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            userId: userId,
            savedOnly: savedOnly,
            prefetchingConfiguration: prefetchingConfiguration
        ))
    }
    
    // MARK: Custom Behavior
    
    override public func refresh(clearBeforeRefresh: Bool) async throws {
        if !clearBeforeRefresh {
            tempPostStream = postStream
            tempCommentStream = commentStream
        }
        
        try await super.refresh(clearBeforeRefresh: clearBeforeRefresh)
        
        tempPostStream = nil
        tempCommentStream = nil
    }
    
    public func changeUser(api: ApiClient, context: FilterContext, userId: Int) async {
        tempPostStream = postStream
        tempCommentStream = commentStream
        
        await singleSourceMixedFetcher.changeApi(to: api, context: context)
        singleSourceMixedFetcher.userId = userId
        await loadingActor.reset()
        await setLoading(.done) // prevent loading more items until refreshed
    }
    
    public func loadIfThreshold(_ item: PersonContent, asChild: Bool) throws {
        let shouldLoad: Bool
        if asChild {
            shouldLoad = switch item.wrappedValue {
            case .post: postStream.thresholds.isThreshold(item)
            case .comment: commentStream.thresholds.isThreshold(item)
            }
        } else {
            shouldLoad = thresholds.isThreshold(item)
        }
        
        // regardless of which threshold triggers this, always call loadMoreItems() because there's no item-specific endpoint
        if shouldLoad {
            Task(priority: .userInitiated) {
                try await loadMoreItems()
            }
        }
    }
    
    public func setPrefetchingConfiguration(_ config: PrefetchingConfiguration) {
        postStream.prefetchingConfiguration = config
        commentStream.prefetchingConfiguration = config
        
        postStream.preloadImages(items)
        // note that this currently doesn't do anything because comments don't support prefetching yet [Eric 2024.11.13]
        commentStream.preloadImages(items)
    }
}
