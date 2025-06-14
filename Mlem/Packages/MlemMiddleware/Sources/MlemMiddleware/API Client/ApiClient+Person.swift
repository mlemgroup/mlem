//
//  NewApiClient+User.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public extension ApiClient {
    func decodePerson(_ data: Person1.CodedData) async throws -> Person1 {
        guard data.apiUrl == baseUrl else {
            throw ApiClientError.mismatchingUrl
        }
        guard try await data.apiMyPersonId == myPersonId else {
            throw ApiClientError.mismatchingPersonId
        }
        return try await caches.person1.getModel(
            api: self,
            from: .init(from: data.apiPerson),
            isStale: true
        )
    }
    
    func decodePerson(_ data: Person2.CodedData) async throws -> Person2 {
        guard data.apiUrl == baseUrl else {
            throw ApiClientError.mismatchingUrl
        }
        guard try await data.apiMyPersonId == myPersonId else {
            throw ApiClientError.mismatchingPersonId
        }
        return try await caches.person2.getModel(
            api: self,
            from: .init(from: data.apiPersonView),
            isStale: true
        )
    }
    
    func getPerson(id: Int) async throws -> Person3 {
        let response = try await performingForConnection { connection in
            try await connection.getPerson(id: id)
        }
        return await caches.person3.getModel(api: self, from: response)
    }
    
    func getPerson(url: URL) async throws -> Person2 {
        let response: Person2Snapshot = try await performingForConnection { connection in
            try await connection.getPerson(url: url)
        }
        return await caches.person2.getModel(api: self, from: response)
    }
    
    func getPerson(username: String) async throws -> Person3 {
        let response: Person3Snapshot = try await performingForConnection { connection in
            try await connection.getPerson(username: username)
        }
        return await caches.person3.getModel(api: self, from: response)
    }
    
    func getPerson(url: URL) async throws -> Person3 {
        let response: Person3Snapshot = try await performingForConnection { connection in
            try await connection.getPerson(url: url)
        }
        return await caches.person3.getModel(api: self, from: response)
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Person2] {
        let response = try await performingForConnection { connection in
            try await connection.searchPeople(
                query: query,
                page: page,
                limit: limit,
                filter: filter,
                sort: sort
            )
        }
        return await caches.person2.getModels(api: self, from: response)
    }
    
    @discardableResult
    func blockPerson(id: Int, block: Bool, semaphore: UInt? = nil) async throws -> Person2 {
        let response = try await performingForConnection { connection in
            try await connection.blockPerson(id: id, block: block)
        }
        return await caches.person2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func banPersonFromCommunity(
        personId: Int,
        communityId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person2 {
        let response = try await performingForConnection { connection in
            try await connection.banPersonFromCommunity(
                personId: personId,
                communityId: communityId,
                ban: ban,
                removeContent: removeContent,
                reason: reason,
                expires: expires
            )
        }
        let person = await caches.person2.getModel(
            api: self,
            from: response
        )
        person.person1.updateKnownCommunityBanState(id: communityId, banned: ban)
        return person
    }
    
    @discardableResult
    func banPersonFromInstance(
        personId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person2 {
        let response = try await performingForConnection { connection in
            try await connection.banPersonFromInstance(
                personId: personId,
                ban: ban,
                removeContent: removeContent,
                reason: reason,
                expires: expires
            )
        }
        return await caches.person2.getModel(
            api: self,
            from: response
        )
    }
    
    func purgePerson(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgePerson(id: id, reason: reason)
        }
        caches.person1.retrieveModel(cacheId: id)?.purged = true
    }
    
    func getContent(
        authorId id: Int,
        sort: PostSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3, posts: [Post2], comments: [Comment2]) {
        let response = try await performingForConnection { connection in
            try await connection.getContent(
                authorId: id,
                sort: sort,
                page: page,
                limit: limit,
                savedOnly: savedOnly,
                communityId: communityId
            )
        }
        return await (
            person: caches.person3.getModel(api: self, from: response.person),
            posts: caches.post2.getModels(api: self, from: response.posts),
            comments: caches.comment2.getModels(api: self, from: response.comments)
        )
    }
    
    func getMyPerson() async throws -> (person: Person4?, instance: Instance3, blocks: BlockList?) {
        let response = try await performingForConnection { connection in
            try await connection.getMyPerson()
        }
        guard response.person?.person.person.person.name == username else {
            assertionFailure()
            throw ApiClientError.mismatchingToken
        }
        
        let instance = await caches.instance3.getModel(api: self, from: response.instance)
        let person = await caches.person4.getOptionalModel(api: self, from: response.person)

        var blocks: BlockList? = blocks
        
        if let person, let newBlocks = response.blocks {
            if let blocks {
                blocks.update(blocks: newBlocks)
            } else {
                blocks = .init(api: self, blocks: newBlocks)
            }
        }
        _ = await Task { @MainActor in
            self.blocks = blocks
            myPerson = person
            myInstance = instance
        }.result
        return (person: person, instance: instance, blocks: blocks)
    }
    
    func deleteAccount(password: String, deleteContent: Bool) async throws {
        try await performingForConnection { connection in
            try await connection.deleteAccount(password: password, deleteContent: deleteContent)
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
