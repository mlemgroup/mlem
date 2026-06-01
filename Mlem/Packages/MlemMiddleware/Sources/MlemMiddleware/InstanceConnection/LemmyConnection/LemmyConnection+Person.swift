//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension LemmyConnection {
    func getPerson(id: Int) async throws -> Person3Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyReadPersonRequest(
                endpoint: endpoint,
                personId: id,
                username: nil,
                sort: .new,
                page: 1,
                limit: 1,
                communityId: nil,
                savedOnly: nil
            )
        }
        return try .init(from: response)
    }
    
    func getPerson(url: URL) async throws -> Person2Snapshot {
        let result = try await resolve(url: url)
        switch result {
        case let .person(person):
            return person
        default:
            throw ApiClientError.noEntityFound
        }
    }
    
    func getPerson(username: String) async throws -> Person3Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyReadPersonRequest(
                endpoint: endpoint,
                personId: nil,
                username: username,
                sort: nil,
                page: nil,
                limit: nil,
                communityId: nil,
                savedOnly: nil
            )
        }
        return try .init(from: response)
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Person2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            try LemmySearchRequest(
                endpoint: endpoint,
                q: query,
                communityId: nil,
                communityName: nil,
                creatorId: nil,
                type_: .users,
                sort: sort.apiType(for: endpoint),
                listingType: filter.apiType,
                page: page,
                limit: limit,
                postTitleOnly: false,
                searchTerm: query,
                searchTitleOnly: false
            )
        }
        return try response.users?.map { try .init(from: $0) } ?? []
    }
    
    @discardableResult
    func blockPerson(id: Int, block: Bool) async throws -> Person2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyUserBlockPersonRequest(endpoint: endpoint, personId: id, block: block)
        }
        switch response {
        case let .lemmyBlockPersonResponse(response):
            return try .init(from: response.personView)
        case let .lemmyPersonResponse(response):
            return try .init(from: response.personView)
        }
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
        let expiryTimestamp: Int?
        if let expires {
            expiryTimestamp = Int(expires.timeIntervalSince1970)
        } else {
            expiryTimestamp = nil
        }
        let response = try await performingForEndpoint { endpoint in
            LemmyBanFromCommunityRequest(
                endpoint: endpoint,
                communityId: communityId,
                personId: personId,
                ban: ban,
                removeData: removeContent,
                reason: reason,
                expires: expiryTimestamp,
                removeOrRestoreData: removeContent,
                expiresAt: expiryTimestamp
            )
        }
        switch response {
        case let .lemmyBanFromCommunityResponse(response):
            guard response.banned == ban else { throw ApiClientError.unsuccessful }
            return try .init(from: response.personView.person)
        case let .lemmyPersonResponse(response):
            return try .init(from: response.personView.person)
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
        let expiryTimestamp: Int?
        if let expires {
            expiryTimestamp = Int(expires.timeIntervalSince1970)
        } else {
            expiryTimestamp = nil
        }
        let response = try await performingForEndpoint { endpoint in
            LemmyBanFromSiteRequest(
                endpoint: endpoint,
                personId: personId,
                ban: ban,
                removeData: removeContent,
                reason: reason,
                expires: expiryTimestamp,
                removeOrRestoreData: removeContent,
                expiresAt: expiryTimestamp
            )
        }
        return try .init(from: response.personView)
    }
    
    func purgePerson(id: Int, reason: String?) async throws {
        let response = try await performingForEndpoint { endpoint in
            LemmyPurgePersonRequest(endpoint: endpoint, personId: id, reason: reason)
        }
        guard response.success else { throw ApiClientError.unsuccessful }
    }
    
    func getContent(
        authorId id: Int,
        sort: PostSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot]) {
        let response = try await performingForEndpoint { endpoint in
            if endpoint == .v4 {
                // TODO: Use LemmyListPersonContentRequest here
                throw ApiClientError.featureUnsupported
            }
            return LemmyReadPersonRequest(
                endpoint: endpoint,
                personId: id,
                username: nil,
                sort: sort.v3ApiType,
                page: page,
                limit: limit,
                communityId: nil,
                savedOnly: savedOnly
            )
        }
        return try (
            person: .init(from: response),
            posts: response.posts?.map { try .init(from: $0) } ?? [],
            comments: response.comments?.map { try .init(from: $0) } ?? []
        )
    }
    
    func getMyPerson() async throws -> (person: Person4Snapshot?, instance: Instance3Snapshot, blocks: BlockListSnapshot?) {
        let rawContext = try await getRawContextWithCaching()
        var person: Person4Snapshot?
        var blocks: BlockListSnapshot?
        if let myUser = rawContext.myUser {
            person = try .init(from: myUser)
            blocks = try .init(from: myUser)
        }
        
        return try (
            person: person,
            instance: .init(from: rawContext.site),
            blocks: blocks
        )
    }
    
    func deleteAccount(password: String, deleteContent: Bool) async throws {
        let response = try await performingForEndpoint { endpoint in
            LemmyDeleteAccountRequest(
                endpoint: endpoint,
                password: password,
                deleteContent: deleteContent
            )
        }
        guard response.success else {
            throw ApiClientError.unsuccessful
        }
    }

    func editNote(id: Int, content: String?) async throws {
        throw ApiClientError.featureUnsupported
    }

    func editProfile(details: ProfileDetails) async throws {
        let response = try await performingForEndpoint { endpoint in
            LemmySaveUserSettingsRequest(
                endpoint: endpoint,
                showNsfw: nil,
                blurNsfw: nil,
                autoExpand: nil,
                showScores: nil,
                theme: nil,
                defaultSortType: nil,
                defaultListingType: nil,
                interfaceLanguage: nil,
                avatar: details.avatar?.absoluteString ?? "",
                banner: details.banner?.absoluteString ?? "",
                displayName: details.displayName,
                email: nil,
                bio: details.description,
                matrixUserId: details.matrixUserId,
                showAvatars: nil,
                sendNotificationsToEmail: nil,
                botAccount: nil,
                showBotAccounts: nil,
                showReadPosts: nil,
                discussionLanguages: nil,
                openLinksInNewTab: nil,
                infiniteScrollEnabled: nil,
                postListingMode: nil,
                enableKeyboardNavigation: nil,
                enableAnimatedImages: nil,
                collapseBotComments: nil,
                showUpvotes: nil,
                showDownvotes: nil,
                showUpvotePercentage: nil,
                defaultPostSortType: nil,
                defaultPostTimeRangeSeconds: nil,
                defaultItemsPerPage: nil,
                defaultCommentSortType: nil,
                blockingKeywords: nil,
                animatedImagesEnabled: nil,
                privateMessagesEnabled: nil,
                showScore: nil,
                autoMarkFetchedPostsAsRead: nil,
                hideMedia: nil,
                showPersonVotes: nil
            )
        }
        guard response.success else {
            throw ApiClientError.unsuccessful
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
        let response = try await performingForEndpoint { endpoint in
            LemmySaveUserSettingsRequest(
                endpoint: endpoint,
                showNsfw: showNsfw,
                blurNsfw: blurNsfw,
                autoExpand: autoExpand,
                showScores: showScores,
                theme: theme,
                defaultSortType: nil,
                defaultListingType: defaultListingType?.apiType,
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
                infiniteScrollEnabled: infiniteScrollEnabled,
                postListingMode: postListingMode?.apiType,
                enableKeyboardNavigation: enableKeyboardNavigation,
                enableAnimatedImages: enableAnimatedImages,
                collapseBotComments: collapseBotComments,
                showUpvotes: showUpvotes,
                showDownvotes: showDownvotes.map { .init(showVotes: $0) },
                showUpvotePercentage: showUpvotePercentage,
                defaultPostSortType: nil,
                defaultPostTimeRangeSeconds: nil,
                defaultItemsPerPage: nil,
                defaultCommentSortType: nil,
                blockingKeywords: nil,
                animatedImagesEnabled: nil,
                privateMessagesEnabled: nil,
                showScore: nil,
                autoMarkFetchedPostsAsRead: nil,
                hideMedia: nil,
                showPersonVotes: nil
            )
        }
        guard response.success else {
            throw ApiClientError.unsuccessful
        }
    }
}
