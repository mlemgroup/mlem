//
//  PersonContentFeedLoader.swift
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
/// The PersonContentFeedLoader is the parent loader. It is responsible for all data fetching, and keeps track of two
/// PersonContentStreams, one for Posts and one for Comments. To load a page of items, it consumes and merges the child streams, just as
/// in the standard Parent/Child FeedLoader; if either stream reaches the end of its items, it triggers a new load, the response from
/// which is then incorporated into both child streams.

@Observable
class PersonContentFetcher: Fetcher<PersonContent> {
    var sortType: FeedLoaderSort.SortType
    var userId: Int
    var savedOnly: Bool
    
    var postStream: PersonContentStream<Post2>
    var commentStream: PersonContentStream<Comment2>
    
    init(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        userId: Int,
        savedOnly: Bool,
        withContent: (posts: [Post2], comments: [Comment2])?,
        prefetchingConfiguration: PrefetchingConfiguration
    ) {
        self.sortType = sortType
        self.userId = userId
        self.savedOnly = savedOnly
        self.postStream = .init(items: withContent?.posts, prefetchingConfiguration: prefetchingConfiguration)
        self.commentStream = .init(items: withContent?.comments, prefetchingConfiguration: prefetchingConfiguration)
        
        super.init(api: api, pageSize: pageSize, page: withContent == nil ? 0 : 1)
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
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        fatalError("Unsupported loading operation")
    }
    
    override func fetchCursor(_ cursor: String) async throws -> FetchResponse {
        fatalError("Unsupported loading operation")
    }
    
    /// Returns the next post or comment, depending on which is sorted first
    private func computeNextItem() async throws -> PersonContent? {
        // if either postStream or commentStream needs items, load the next page from the API
        if postStream.needsMoreItems || commentStream.needsMoreItems {
            page += 1
            let response = try await api.getContent(authorId: userId, sort: .new, page: page, limit: pageSize, savedOnly: savedOnly)
            postStream.addItems(response.posts)
            commentStream.addItems(response.comments)
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

@Observable
public class PersonContentFeedLoader: StandardFeedLoader<PersonContent> {
    // force unwrap because this should ALWAYS be a PersonContentFetcher
    @ObservationIgnored var personContentFetcher: PersonContentFetcher { fetcher as! PersonContentFetcher }
    
    @ObservationIgnored public var api: ApiClient { personContentFetcher.api }
    @ObservationIgnored public var userId: Int { personContentFetcher.userId }
    
    // MARK: Custom Behavior

    // This FeedLoader is slightly awkward because it functions like a multi-loader but draws its posts and comments from a single API call. The streams act essentially like child loaders, but are populated using custom behavior in the fetcher. This FeedLoader is best understood as a multi-loader with the streams as child loaders.
    
    private var postStream: PersonContentStream<Post2> { personContentFetcher.postStream }
    private var commentStream: PersonContentStream<Comment2> { personContentFetcher.commentStream }
    
    // these are used to allow refresh without clear
    private var tempPostStream: PersonContentStream<Post2>?
    private var tempCommentStream: PersonContentStream<Comment2>?
    
    // convenience accessors for child types
    public var posts: [PersonContent] { tempPostStream?.items ?? postStream.items }
    public var postLoadingState: LoadingState { postStream.doneLoading ? .done : loadingState }
    
    public var comments: [PersonContent] { tempCommentStream?.items ?? commentStream.items }
    public var commentLoadingState: LoadingState { commentStream.doneLoading ? .done : loadingState }
    
    public init(
        api: ApiClient,
        pageSize: Int,
        userId: Int,
        sortType: FeedLoaderSort.SortType,
        savedOnly: Bool,
        prefetchingConfiguration: PrefetchingConfiguration,
        withContent: (posts: [Post2], comments: [Comment2])? = nil
    ) {
        super.init(filter: MultiFilter(), fetcher: PersonContentFetcher(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            userId: userId,
            savedOnly: savedOnly,
            withContent: withContent,
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
        
        await personContentFetcher.changeApi(to: api, context: context)
        personContentFetcher.userId = userId
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
        
        if asChild {
            switch item.wrappedValue {
            case .post: print("DEBUG \(shouldLoad ? "should" : "should not") load posts")
            case .comment: print("DEBUG \(shouldLoad ? "should" : "should not") load comments")
            }
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
