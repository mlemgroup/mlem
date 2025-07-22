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
        do {
            let request = PieFedResolveObjectRequest(q: url.absoluteString)
            let response = try await perform(request)
            if let person = response.person {
                return try .init(from: person)
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
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
    
    func getPerson(url: URL) async throws -> Person3Snapshot {
        let person: Person2Snapshot = try await getPerson(url: url)
        return try await getPerson(id: person.person.id)
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Person2Snapshot] {
        guard let sort = sort.pieFedSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedSearchRequest(
            q: query,
            type_: .users,
            sort: sort,
            listingType: filter.pieFedListingType,
            page: page,
            limit: limit
        )
        let response = try await perform(request)
        return try response.users.map { try .init(from: $0) }
    }
    
    @discardableResult
    func blockPerson(id: Int, block: Bool) async throws -> Person2Snapshot {
        let request = PieFedBlockPersonRequest(personId: id, block: block)
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if ban {
            let request = PieFedModerateCommunityBanRequest(
                communityId: communityId,
                userId: personId,
                reason: reason ?? "",
                expiredAt: formatter.string(from: expires ?? .distantFuture)
            )
            let response = try await perform(request)
            return try .init(from: response.bannedUser)
        } else {
            let request = PieFedModerateCommunityUnBanRequest(
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
        page: Int,
        limit: Int,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot]) {
        let request = PieFedGetPersonDetailsRequest(
            personId: id,
            username: nil,
            sort: .new,
            page: page,
            limit: limit,
            communityId: nil,
            savedOnly: nil,
            includeContent: true
        )
        let response = try await perform(request)
        return try (
            person: .init(from: response),
            posts: response.posts.map { try .init(from: $0) },
            comments: response.comments.map { try .init(from: $0) }
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
