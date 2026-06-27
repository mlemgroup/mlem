//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension PieFedConnection {
    func getPerson(id: Int) async throws -> Person3Snapshot {
        let request = PieFedGetPersonDetailsRequest(
            personId: id,
            username: nil,
            sort: .new,
            page: 1,
            limit: 1,
            communityId: nil,
            savedOnly: nil,
            includeContent: false
        )
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func getPerson(url: URL) async throws -> Person2Snapshot {
        let request = PieFedResolveObjectRequest(q: url.absoluteString)
        let response = try await perform(request)
        if let person = response.person {
            return try .init(from: person)
        }
        throw ApiClientError.noEntityFound
    }
    
    func getPerson(username: String) async throws -> Person3Snapshot {
        let request = PieFedGetPersonDetailsRequest(
            personId: nil,
            username: username,
            sort: .new,
            page: 1,
            limit: 1,
            communityId: nil,
            savedOnly: nil,
            includeContent: false
        )
        let response = try await perform(request)
        return try .init(from: response)
    }

    func getPerson(handle: PersonHandle) async throws -> Person2Snapshot {
        let request = PieFedResolveObjectRequest(q: handle.description(withPrefix: true))
        let response = try await perform(request)
        if let person = response.person {
            return try .init(from: person)
        }
        throw ApiClientError.noEntityFound
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType = .all,
        sort: PersonSortType
    ) async throws -> PagedResponse<Person2Snapshot> {
        guard let sort = sort.pieFedSearchSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedSearchRequest(
            q: query,
            type_: .users,
            limit: pageInfo.limit,
            listingType: filter.pieFedListingType,
            page: try pageInfo.cursor.requirePageNumber,
            sort: sort,
            communityName: nil,
            communityId: nil,
            minimumUpvotes: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.users.map { try .init(from: $0) }
        )
    }
    
    @discardableResult
    func blockPerson(id: Int, block: Bool) async throws -> Person2Snapshot {
        let request = PieFedUserBlockRequest(block: block, personId: id)
        let response = try await perform(request)
        return try .init(from: response.personView)
    }
    
    @discardableResult
    func banPersonFromCommunity(
        personId: Int,
        communityId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person1Snapshot {
        if ban {
            let request = PieFedCommunityModerationBanRequest(
                communityId: communityId,
                reason: reason ?? "",
                userId: personId,
                expiresAt: expires,
                permanent: expires == nil
            )
            let response = try await perform(request)
            return try .init(from: response.bannedUser)
        } else {
            let request = PieFedCommunityModerationUnbanRequest(
                communityId: communityId,
                userId: personId
            )
            let response = try await perform(request)
            return try .init(from: response.bannedUser)
        }
    }
    
    @discardableResult
    func banPersonFromInstance(
        personId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    func purgePerson(id: Int, reason: String?) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    func getContent(
        authorId id: Int,
        sort: PostSortType,
        pageInfo: PageInfo,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot], nextLocation: PageLocation) {
        let request = PieFedGetPersonDetailsRequest(
            personId: id,
            username: nil,
            sort: .new,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityId: nil,
            savedOnly: nil,
            includeContent: true
        )
        let response = try await perform(request)

        let nextLocation: PageLocation
        if response.posts.count < pageInfo.limit && response.comments.count < pageInfo.limit {
            nextLocation = .end
        } else {
            nextLocation = .at(try pageInfo.cursor.stepForward())
        }

        return try (
            person: .init(from: response),
            posts: response.posts.map { try .init(from: $0) },
            comments: response.comments.map { try .init(from: $0) },
            nextLocation: nextLocation
        )
    }
    
    // Returns a raw API type. For use inside PieFedConnection only
    internal func rawGetMyPerson() async throws -> (PieFedGetSiteResponse, PieFedLemmyCompatibleSiteResponse) {
        async let pieFedResponse = await perform(PieFedGetSiteRequest())
        async let lemmyResponse = await perform(PieFedLemmyCompatibleGetSiteRequest())
        return try await (pieFedResponse, lemmyResponse)
    }
    
    // Calls rawGetMyPerson, but if there's already a task running in the `contextDataManager` uses that instead.
    internal func rawGetMyPersonWithContext() async throws -> (PieFedGetSiteResponse, PieFedLemmyCompatibleSiteResponse) {
        if let ongoingTask = contextDataManager.ongoingTask {
            return try await ongoingTask.result.get()
        } else {
            let task = Task { try await rawGetMyPerson() }
            Task.detached {
                _ = try await self.contextDataManager.getValue(task: task)
            }
            return try await task.result.get()
        }
    }
    
    func getMyPerson() async throws -> (person: Person4Snapshot?, instance: Instance3Snapshot, blocks: BlockListSnapshot?) {
        let response = try await rawGetMyPersonWithContext()
        var person: Person4Snapshot?
        var blocks: BlockListSnapshot?
        if let myUser = response.0.myUser {
            person = try .init(from: myUser)
            blocks = .init(from: myUser)
        }
        
        return try (
            person: person,
            instance: .init(pieFed: response.0, lemmy: response.1),
            blocks: blocks
        )
    }
    
    func deleteAccount(password: String, deleteContent: Bool) async throws {
        throw ApiClientError.featureUnsupported
    }

    func editNote(id: Int, content: String?) async throws {
        let request = PieFedUserSetNoteRequest(personId: id, note: content ?? "")
        try await perform(request)
    }
    
    func editProfile(details: ProfileDetails) async throws {
        let request = PieFedUserSaveSettingsRequest(
            avatar: details.avatar?.absoluteString ?? "",
            bio: details.description,
            cover: details.banner?.absoluteString ?? "",
            defaultCommentSortType: nil,
            defaultSortType: nil,
            extraFields: nil,
            showNsfw: nil,
            showNsfl: nil,
            showReadPosts: nil,
            acceptPrivateMessages: nil,
            bot: nil,
            botVisibility: nil,
            communityKeywordFilter: nil,
            emailUnread: nil,
            federateVotes: nil,
            feedAutoFollow: nil,
            feedAutoLeave: nil,
            hideLowQuality: nil,
            indexable: nil,
            newsletter: nil,
            nsflVisibility: nil,
            nsfwVisibility: nil,
            genaiVisibility: nil,
            replyCollapseThreshold: nil,
            replyHideThreshold: nil,
            searchable: nil,
            displayName: nil
        )
        try await perform(request)
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
        throw ApiClientError.featureUnsupported
    }
}
