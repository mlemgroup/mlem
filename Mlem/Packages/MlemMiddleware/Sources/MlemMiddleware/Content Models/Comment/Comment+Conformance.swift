//
//  Comment+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-19.
//

// MARK: CacheIdentifiable

public extension Comment {
    var cacheId: Int { id }
}

// MARK: ContentModel

public extension Comment {
    static var tierNumber: Int = 4
}

// MARK: FeedLoadable

public extension Comment {
    typealias FilterType = CommentFilterType
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// MARK: SelectableContentProviding

public extension Comment {
    var selectableContent: String? { content }
}

// MARK: ContentIdentifiable

public extension Comment {
    static var modelTypeId: ContentType { .comment }
}

// MARK: OwnershipProviding

public extension Comment {
    func isOwnContent(myPersonId: Int) -> Bool {
        creatorId == myPersonId
    }
}

// MARK: Interactable1Providing (shimmed)

public extension Comment {
    // these are all shims! auto-fetching is therefore disabled to avoid unwanted side effects
    var creator_: (any Person)? { creator.value_ }
    
    var community_: (any Community)? { community.value_ }
    
    var creatorIsModerator_: Bool? { creatorIsModerator.value_ }
    
    var creatorIsAdmin_: Bool? { creatorIsAdmin.value_ }
    
    var creatorBannedFromCommunity_: Bool? { creatorBannedFromCommunity.value_ }
    
    var commentCount_: Int? { commentCount.value_ }
    
    var votes_: VotesModel? { votes.value_ }
    
    var saved_: Bool? { saved.value_ }
    
    func report(reason: String) async throws {
        try await api.reportPost(id: id, reason: reason)
    }
}

// MARK: CanModerateProviding

public extension Comment {
    // TODO: NOW should this be expected?
    var canModerate: Bool {
        guard let id = community.value_?.id as? Int else { return false }
        return api.myPerson?.moderates(communityId: id) ?? false || api.isAdmin
    }
}

// MARK: CommentResolvable

public extension Comment {
    func asComment() async throws -> Comment { self }
}
