//
//  ApiRepository+Person.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

import Foundation

extension ApiRepository {
    func getPerson(id: Int) async throws -> Person3Snapshot {
        try await performingForConnection { connection in
            try await connection.getPerson(id: id)
        }
    }
    
    func getPerson(url: URL) async throws -> Person2Snapshot {
        try await performingForConnection { connection in
            try await connection.getPerson(url: url)
        }
    }
    
    func getPerson(username: String) async throws -> Person3Snapshot {
        try await performingForConnection { connection in
            try await connection.getPerson(username: username)
        }
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType = .all,
        sort: PersonSortType
    ) async throws -> PagedResponse<Person2Snapshot> {
        try await performingForConnection { connection in
            try await connection.searchPeople(
                query: query,
                pageInfo: pageInfo,
                filter: filter,
                sort: sort
            )
        }
    }
    
    func blockPerson(id: Int, block: Bool, semaphore: UInt? = nil) async throws -> Person2Snapshot {
        try await performingForConnection { connection in
            try await connection.blockPerson(id: id, block: block)
        }
    }
    
    func banPersonFromCommunity(
        personId: Int,
        communityId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person1Snapshot {
        try await performingForConnection { connection in
            try await connection.banPersonFromCommunity(
                personId: personId,
                communityId: communityId,
                ban: ban,
                removeContent: removeContent,
                reason: reason,
                expires: expires
            )
        }
    }
    
    func banPersonFromInstance(
        personId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person2Snapshot {
        try await performingForConnection { connection in
            try await connection.banPersonFromInstance(
                personId: personId,
                ban: ban,
                removeContent: removeContent,
                reason: reason,
                expires: expires
            )
        }
    }
    
    func purgePerson(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgePerson(id: id, reason: reason)
        }
    }
    
    func getContent(
        authorId id: Int,
        sort: PostSortType,
        pageInfo: PageInfo,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot]) {
        try await performingForConnection { connection in
            try await connection.getContent(
                authorId: id,
                sort: sort,
                pageInfo: pageInfo,
                savedOnly: savedOnly,
                communityId: communityId
            )
        }
    }
    
    func getMyPerson() async throws -> (person: Person4Snapshot?, instance: Instance3Snapshot, blocks: BlockListSnapshot?) {
        try await performingForConnection { connection in
            try await connection.getMyPerson()
        }
    }
    
    func deleteAccount(password: String, deleteContent: Bool) async throws {
        try await performingForConnection { connection in
            try await connection.deleteAccount(password: password, deleteContent: deleteContent)
        }
    }

    func editNote(id: Int, content: String?) async throws {
        try await performingForConnection { connection in
            try await connection.editNote(id: id, content: content)
        }
    }

    func editProfile(_ details: ProfileDetails) async throws {
        try await performingForConnection { connection in
            try await connection.editProfile(details: details)
        }
    }
    
    func editAccountSettings(
        showNsfw: Bool?,
        showScores: Bool?,
        theme: String?,
        defaultListingType: ListingType?,
        interfaceLanguage: String?,
        avatar: String?,
        banner: String?,
        displayName: String?,
        email: String?,
        bio: String?,
        matrixUserId: String?,
        showAvatars: Bool?,
        sendNotificationsToEmail: Bool?,
        botAccount: Bool?,
        showBotAccounts: Bool?,
        showReadPosts: Bool?,
        discussionLanguages: [Int]?,
        openLinksInNewTab: Bool?,
        blurNsfw: Bool?,
        autoExpand: Bool?,
        infiniteScrollEnabled: Bool?,
        postListingMode: PostFeedViewMode?,
        enableKeyboardNavigation: Bool?,
        enableAnimatedImages: Bool?,
        collapseBotComments: Bool?,
        showUpvotes: Bool?,
        showDownvotes: Bool?,
        showUpvotePercentage: Bool?
    ) async throws {
        try await performingForConnection { connection in
            try await connection.editAccountSettings(
                showNsfw: showNsfw,
                showScores: showScores,
                theme: theme,
                defaultListingType: defaultListingType,
                interfaceLanguage: interfaceLanguage,
                avatar: avatar,
                banner: banner,
                displayName: displayName,
                email: email,
                bio: bio,
                matrixUserId: matrixUserId,
                showAvatars: showAvatars,
                sendNotificationsToEmail: sendNotificationsToEmail,
                botAccount: botAccount,
                showBotAccounts: showBotAccounts,
                showReadPosts: showReadPosts,
                discussionLanguages: discussionLanguages,
                openLinksInNewTab: openLinksInNewTab,
                blurNsfw: blurNsfw,
                autoExpand: autoExpand,
                infiniteScrollEnabled: infiniteScrollEnabled,
                postListingMode: postListingMode,
                enableKeyboardNavigation: enableKeyboardNavigation,
                enableAnimatedImages: enableAnimatedImages,
                collapseBotComments: collapseBotComments,
                showUpvotes: showUpvotes,
                showDownvotes: showDownvotes,
                showUpvotePercentage: showUpvotePercentage
            )
        }
    }
}
