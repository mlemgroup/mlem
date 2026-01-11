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
        let snapshot = try await repository.getPerson(id: id)
        return await caches.person3.getModel(api: self, from: snapshot)
    }
    
    func getPerson(url: URL) async throws -> Person2 {
        let snapshot: Person2Snapshot = try await repository.getPerson(url: url)
        return await caches.person2.getModel(api: self, from: snapshot)
    }
    
    func getPerson(username: String) async throws -> Person3 {
        let snapshot: Person3Snapshot = try await repository.getPerson(username: username)
        return await caches.person3.getModel(api: self, from: snapshot)
    }
    
    func getPerson(url: URL) async throws -> Person3 {
        let snapshot: Person3Snapshot = try await repository.getPerson(url: url)
        return await caches.person3.getModel(api: self, from: snapshot)
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Person2] {
        let snapshots = try await repository.searchPeople(
            query: query,
            page: page,
            limit: limit,
            filter: filter,
            sort: sort
        )
        return await caches.person2.getModels(api: self, from: snapshots)
    }
    
    @discardableResult
    func blockPerson(id: Int, block: Bool, semaphore: UInt? = nil) async throws -> Person2 {
        let snapshot = try await repository.blockPerson(id: id, block: block)
        return await caches.person2.getModel(
            api: self,
            from: snapshot,
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
    ) async throws -> Person1 {
        let snapshot = try await repository.banPersonFromCommunity(
            personId: personId,
            communityId: communityId,
            ban: ban,
            removeContent: removeContent,
            reason: reason,
            expires: expires
        )
        let person = await caches.person1.getModel(
            api: self,
            from: snapshot
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
        let snapshot = try await repository.banPersonFromInstance(
            personId: personId,
            ban: ban,
            removeContent: removeContent,
            reason: reason,
            expires: expires
        )
        return await caches.person2.getModel(
            api: self,
            from: snapshot
        )
    }
    
    func purgePerson(id: Int, reason: String?) async throws {
        try await repository.purgePerson(id: id, reason: reason)
        caches.person1.retrieveModel(cacheId: id)?.purged = true
    }
    
    func getContent(
        authorId id: Int,
        sort: PostSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3, posts: [UnifiedPostModel], comments: [Comment2]) {
        let snapshots = try await repository.getContent(
            authorId: id,
            sort: sort,
            page: page,
            limit: limit,
            savedOnly: savedOnly,
            communityId: communityId
        )
        return await (
            person: caches.person3.getModel(api: self, from: snapshots.person),
            posts: caches.post.getModels(api: self, from: snapshots.posts.map { .post2($0) }),
            comments: caches.comment2.getModels(api: self, from: snapshots.comments)
        )
    }
    
    func getMyPerson() async throws -> (person: Person4?, instance: Instance3, blocks: BlockList?) {
        let snapshot = try await repository.getMyPerson()
        let snapshotPersonName = snapshot.person?.person.person.person.name
        guard snapshotPersonName == username else {
            assertionFailure(
                "Returned account name \(String(describing: snapshotPersonName)) does not match logged in username \(String(describing: username))"
            )
            throw ApiClientError.mismatchingToken
        }
        
        let instance = await caches.instance3.getModel(api: self, from: snapshot.instance)
        let person = await caches.person4.getOptionalModel(api: self, from: snapshot.person)
        var blocks: BlockList? = blocks
        
        if person != nil, let newBlocks = snapshot.blocks {
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
        try await repository.deleteAccount(password: password, deleteContent: deleteContent)
    }

    func editProfile(_ details: ProfileDetails) async throws {
        try await repository.editProfile(details)
        let personId = try await myPersonId
        if let personId, let person = caches.person1.retrieveModel(cacheId: personId) {
            person.avatar = details.avatar
            person.banner = details.banner
            person.displayName = details.displayName ?? person.name
            person.description = details.description
            person.matrixId = details.matrixId
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
        try await repository.editAccountSettings(
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
