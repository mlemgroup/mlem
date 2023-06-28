//
//  Replies Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

@MainActor
class RepliesTracker: ObservableObject {
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var replies: [APICommentReplyView] = .init()
    
    // tracks the id of the 10th-from-last item so we know when to load more
    public var loadMarkId: Int = 0
    private var ids: Set<Int> = .init()
    private var page: Int = 1
    
    func loadNextPage(account: SavedAccount) async throws {
        let newReplies = try await loadPage(account: account, page: page)

        guard !newReplies.isEmpty else {
            return
        }

        add(newReplies)
        page += 1
        loadMarkId = replies.count >= 40 ? replies[replies.count - 40].id : 0
    }
    
    func loadPage(account: SavedAccount, page: Int) async throws -> [APICommentReplyView] {
        defer { isLoading = false }
        isLoading = true
        
        let request = GetRepliesRequest(
            account: account,
            page: page,
            limit: 50
        )

        let response = try await APIClient().perform(request: request)

        return response.replies
    }
    
    func add(_ newReplies: [APICommentReplyView]) {
        let accepted = newReplies.filter { ids.insert($0.id).inserted }
        replies = merge(arr1: replies, arr2: accepted, compare: wasPostedAfter)
    }
    
    func refresh(account: SavedAccount) async throws {
        // save to temp variable and then set so that mentions don't vanish while refreshing
        let newReplies = try await loadPage(account: account, page: 1)
        page = 1
        ids = .init()
        replies = newReplies
    }
    
    /**
     Returns true if lhs was posted after rhs
     */
    func wasPostedAfter(lhs: APICommentReplyView, rhs: APICommentReplyView) -> Bool {
        return lhs.commentReply.published > rhs.commentReply.published
    }
}
