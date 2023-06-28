//
//  MentionsTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

@MainActor
class MentionsTracker: ObservableObject {
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var mentions: [APIPersonMentionView] = .init()
    
    // tracks the id of the 10th-from-last item so we know when to load more
    public var loadMarkId: Int = 0
    private var ids: Set<Int> = .init()
    private var page: Int = 1
    
    func loadNextPage(account: SavedAccount, sort: PostSortType?) async throws {
        let nextPage = try await loadPage(account: account, sort: sort, page: page)
        
        guard !nextPage.isEmpty else {
            return
        }
        add(nextPage)
        
        page += 1
        loadMarkId = mentions.count >= 40 ? mentions[mentions.count - 40].id : 0
    }
    
    func loadPage(account: SavedAccount, sort: PostSortType?, page: Int) async throws -> [APIPersonMentionView] {
        defer { isLoading = false }
        isLoading = true
        
        let request = GetPersonMentionsRequest(
            account: account,
            sort: sort,
            page: page,
            limit: 50
        )

        let response = try await APIClient().perform(request: request)

        return response.mentions
    }
    
    func add(_ newMentions: [APIPersonMentionView]) {
        let accepted = newMentions.filter { ids.insert($0.id).inserted }
        mentions = merge(arr1: mentions, arr2: accepted, compare: wasPostedAfter)
    }
    
    func refresh(account: SavedAccount) async throws {
        // save to temp variable and then set so that mentions don't vanish while refreshing
        let newMentions = try await loadPage(account: account, sort: .new, page: 1)
        page = 1
        ids = .init()
        mentions = newMentions
    }
    
    /**
     Returns true if lhs was posted after rhs
     */
    func wasPostedAfter(lhs: APIPersonMentionView, rhs: APIPersonMentionView) -> Bool {
        return lhs.personMention.published > rhs.personMention.published
    }
}
