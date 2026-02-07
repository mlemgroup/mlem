//
//  Person.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Observation
import Foundation

@Observable
public class Person:
    UnifiedModelProviding,
    Blockable,
    ContentIdentifiable,
    SelectableContentProviding,
    Resolvable,
    PurgableProviding,
    Sharable,
    FeedLoadable,
    Profile2Providing { // TODO: UnifiedCommunity unify ProfileProviding
    public typealias Properties = PersonProperties
    
    public var api: ApiClient
    private let properties: PersonProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Person> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
    public var blocked: Bool
    public var purged: Bool = false
    
    // Communities from which this person is *known* to be banned.
    // If an ID is not in this set, its status is unknown.
    //
    // Don't make this public. Instead, use the `bannedFromCommunity` property of
    // Post2/Comment2/Reply2. Accessing it from there guarantees that the ban
    // status is known. Those properties access this set as a shared source-of-truth.
    var knownCommunityBanStates: [Int: Bool] = .init()
    
    // MARK: API Properties
    // Properties that are provided by the API
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let name: String
    public let created: Date
    public let instanceId: Int
    public var displayName: String
    public var avatar: URL?
    public var banner: URL?
    public var note: String?
    public var updated: Date?
    public var description: String?
    public var matrixUserId: String?
    public var isBot: Bool
    public var instanceBan: InstanceBanType
    public var deleted: Bool
    
    public var isAdmin: ExpectedValue<Bool>
    public var postCount: ExpectedValue<Int>
    public var commentCount: ExpectedValue<Int>
    public var instance: ExpectedValue<(any Instance)>
    public var moderatedCommunities: ExpectedValue<[any Community]>
    
    var email: ExpectedValue<String?>
    var showNsfw: ExpectedValue<Bool>
    var theme: ExpectedValue<String>
    var defaultListingType: ExpectedValue<ListingType>
    var interfaceLanguage: ExpectedValue<String>
    var showAvatars: ExpectedValue<Bool>
    var sendNotificationsToEmail: ExpectedValue<Bool>
    var showScores: ExpectedValue<Bool>
    var showBotAccounts: ExpectedValue<Bool>
    var showReadPosts: ExpectedValue<Bool>
    var discussionLanguageIds: ExpectedValue<Set<Int>>
    var emailVerified: ExpectedValue<Bool>
    var acceptedApplication: ExpectedValue<Bool>
    var openLinksInNewTab: ExpectedValue<Bool?>
    var blurNsfw: ExpectedValue<Bool?>
    var autoExpandImages: ExpectedValue<Bool?>
    var infiniteScrollEnabled: ExpectedValue<Bool?>
    var postListingMode: ExpectedValue<PostFeedViewMode?>
    var totp2faEnabled: ExpectedValue<Bool?>
    var enableKeyboardNavigation: ExpectedValue<Bool?>
    var enableAnimatedImages: ExpectedValue<Bool?>
    var collapseBotComments: ExpectedValue<Bool?>
    
    public init(api: ApiClient, properties: PersonProperties) {
        self.api = api
        self.properties = properties
        self.blocked = api.blocks?.people.keys.contains(properties.actorId) ?? false
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.name = properties.name
        self.created = properties.created
        self.instanceId = properties.instanceId
        self.displayName = properties.displayName
        self.avatar = properties.avatar
        self.banner = properties.banner
        self.note = properties.note
        self.updated = properties.updated
        self.description = properties.description
        self.matrixUserId = properties.matrixUserId
        self.isBot = properties.isBot
        self.instanceBan = properties.instanceBan
        self.deleted = properties.deleted
        
        // because upgrade() is not available until all properties are initialized, first populate all properties
        // with ExpectedValues that don't actually do anything, then reassign them properly at the end of the init
        // this is somewhat cumbersome but avoids lazy vars, which are very awkward in Observables
        self.isAdmin = dummyExpectedValue(properties.isAdmin)
        self.postCount = dummyExpectedValue(properties.postCount)
        self.commentCount = dummyExpectedValue(properties.commentCount)
        self.instance = dummyExpectedValue(properties.instance)
        self.moderatedCommunities = dummyExpectedValue(properties.moderatedCommunities)
        
        self.email = dummyExpectedValue(properties.email)
        self.showNsfw = dummyExpectedValue(properties.showNsfw)
        self.theme = dummyExpectedValue(properties.theme)
        self.defaultListingType = dummyExpectedValue(properties.defaultListingType)
        self.interfaceLanguage = dummyExpectedValue(properties.interfaceLanguage)
        self.showAvatars = dummyExpectedValue(properties.showAvatars)
        self.sendNotificationsToEmail = dummyExpectedValue(properties.sendNotificationsToEmail)
        self.showScores = dummyExpectedValue(properties.showScores)
        self.showBotAccounts = dummyExpectedValue(properties.showBotAccounts)
        self.showReadPosts = dummyExpectedValue(properties.showReadPosts)
        self.discussionLanguageIds = dummyExpectedValue(properties.discussionLanguageIds)
        self.emailVerified = dummyExpectedValue(properties.emailVerified)
        self.acceptedApplication = dummyExpectedValue(properties.acceptedApplication)
        self.openLinksInNewTab = dummyExpectedValue(properties.openLinksInNewTab)
        self.blurNsfw = dummyExpectedValue(properties.blurNsfw)
        self.autoExpandImages = dummyExpectedValue(properties.autoExpandImages)
        self.infiniteScrollEnabled = dummyExpectedValue(properties.infiniteScrollEnabled)
        self.postListingMode = dummyExpectedValue(properties.postListingMode)
        self.totp2faEnabled = dummyExpectedValue(properties.totp2faEnabled)
        self.enableKeyboardNavigation = dummyExpectedValue(properties.enableKeyboardNavigation)
        self.enableAnimatedImages = dummyExpectedValue(properties.enableAnimatedImages)
        self.collapseBotComments = dummyExpectedValue(properties.collapseBotComments)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
        self.isAdmin = expectedValue(properties.isAdmin)
        self.postCount = expectedValue(properties.postCount)
        self.commentCount = expectedValue(properties.commentCount)
        self.instance = expectedValue(properties.instance)
        self.moderatedCommunities = expectedValue(properties.moderatedCommunities)
        
        self.email = expectedValue(properties.email)
        self.showNsfw = expectedValue(properties.showNsfw)
        self.theme = expectedValue(properties.theme)
        self.defaultListingType = expectedValue(properties.defaultListingType)
        self.interfaceLanguage = expectedValue(properties.interfaceLanguage)
        self.showAvatars = expectedValue(properties.showAvatars)
        self.sendNotificationsToEmail = expectedValue(properties.sendNotificationsToEmail)
        self.showScores = expectedValue(properties.showScores)
        self.showBotAccounts = expectedValue(properties.showBotAccounts)
        self.showReadPosts = expectedValue(properties.showReadPosts)
        self.discussionLanguageIds = expectedValue(properties.discussionLanguageIds)
        self.emailVerified = expectedValue(properties.emailVerified)
        self.acceptedApplication = expectedValue(properties.acceptedApplication)
        self.openLinksInNewTab = expectedValue(properties.openLinksInNewTab)
        self.blurNsfw = expectedValue(properties.blurNsfw)
        self.autoExpandImages = expectedValue(properties.autoExpandImages)
        self.infiniteScrollEnabled = expectedValue(properties.infiniteScrollEnabled)
        self.postListingMode = expectedValue(properties.postListingMode)
        self.totp2faEnabled = expectedValue(properties.totp2faEnabled)
        self.enableKeyboardNavigation = expectedValue(properties.enableKeyboardNavigation)
        self.enableAnimatedImages = expectedValue(properties.enableAnimatedImages)
        self.collapseBotComments = expectedValue(properties.collapseBotComments)
    }
    
    public func update(with properties: PersonProperties) {
        setIfChanged(\.displayName, properties.displayName)
        setIfChanged(\.avatar, properties.avatar)
        setIfChanged(\.banner, properties.banner)
        setIfChanged(\.note, properties.note)
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.description, properties.description)
        setIfChanged(\.matrixUserId, properties.matrixUserId)
        setIfChanged(\.isBot, properties.isBot)
        setIfChanged(\.instanceBan, properties.instanceBan)
        setIfChanged(\.deleted, properties.deleted)
        
        setIfChanged(\.isAdmin.value_, properties.isAdmin)
        setIfChanged(\.postCount.value_, properties.postCount)
        setIfChanged(\.commentCount.value_, properties.commentCount)
        
        setIfNil(\.instance.value_, properties.instance)
        // TODO: NOW
        // setIfChanged(\.moderatedCommunities.value_, properties.moderatedCommunities)
        
        // TODO: NOW setIfChanged don't update if existing non-nil and incoming nil
        setIfChanged(\.email.value_, properties.email)
        setIfChanged(\.showNsfw.value_, properties.showNsfw)
        setIfChanged(\.theme.value_, properties.theme)
        setIfChanged(\.defaultListingType.value_, properties.defaultListingType)
        setIfChanged(\.interfaceLanguage.value_, properties.interfaceLanguage)
        setIfChanged(\.showAvatars.value_, properties.showAvatars)
        setIfChanged(\.sendNotificationsToEmail.value_, properties.sendNotificationsToEmail)
        setIfChanged(\.showScores.value_, properties.showScores)
        setIfChanged(\.showBotAccounts.value_, properties.showBotAccounts)
        setIfChanged(\.showReadPosts.value_, properties.showReadPosts)
        setIfChanged(\.discussionLanguageIds.value_, properties.discussionLanguageIds)
        setIfChanged(\.emailVerified.value_, properties.emailVerified)
        setIfChanged(\.acceptedApplication.value_, properties.acceptedApplication)
        setIfChanged(\.openLinksInNewTab.value_, properties.openLinksInNewTab)
        setIfChanged(\.blurNsfw.value_, properties.blurNsfw)
        setIfChanged(\.autoExpandImages.value_, properties.autoExpandImages)
        setIfChanged(\.infiniteScrollEnabled.value_, properties.infiniteScrollEnabled)
        setIfChanged(\.postListingMode.value_, properties.postListingMode)
        setIfChanged(\.totp2faEnabled.value_, properties.totp2faEnabled)
        setIfChanged(\.enableKeyboardNavigation.value_, properties.enableKeyboardNavigation)
        setIfChanged(\.enableAnimatedImages.value_, properties.enableAnimatedImages)
        setIfChanged(\.collapseBotComments.value_, properties.collapseBotComments)
    }
    
    public func softUpdate(with properties: PersonProperties) {
        setIfNil(\.isAdmin.value_, properties.isAdmin)
        setIfNil(\.postCount.value_, properties.postCount)
        setIfNil(\.commentCount.value_, properties.commentCount)
        
        setIfNil(\.instance.value_, properties.instance)
        setIfNil(\.moderatedCommunities.value_, properties.moderatedCommunities)
    }
    
    // MARK: Upgrades
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func fetchUpgraded() async throws -> PersonProperties {
        let snapshot = try await api.repository.getPerson(id: id)
        return await .init(api: api, snapshot: .person3(snapshot))
    }
    
    // MARK: Logic
    
    func updateKnownCommunityBanState(id: Int, banned: Bool) {
        if banned {
            // This `if` statement avoids unneccessary state update
            if !(knownCommunityBanStates[id] ?? false) {
                knownCommunityBanStates[id] = true
            }
        } else {
            if knownCommunityBanStates[id] ?? true {
                knownCommunityBanStates[id] = false
            }
        }
    }
}

// MARK: - Computed

public extension Person {
    var isMlemDeveloper: Bool {
        BackendClient.main.flairs.developers.contains(actorId.description)
    }
    
    var bannedFromInstance: Bool { instanceBan != .notBanned }
    
    func isBannedFromCommunity(id: Int) -> Bool? {
        knownCommunityBanStates[id]
    }
    
    func isBannedFromCommunity(_ community: any Community) -> Bool? {
        isBannedFromCommunity(id: community.id)
    }
    
    func profileDetails() -> ProfileDetails {
        .init(
            avatar: avatar,
            banner: banner,
            displayName: displayName,
            description: description,
            matrixId: matrixUserId // TODO: NOW figure out naming
        )
    }
    
    var moderatedCommunityActorIds: Set<ActorIdentifier>? {
        if let moderatedCommunities = moderatedCommunities.value {
            .init(moderatedCommunities.map(\.actorId))
        } else {
            nil
        }
    }
    
    var moderates: ((CommunityIdentifier) -> Bool)? {
        if let moderatedCommunities = moderatedCommunities.value {
            return { communityIdentifier in
                switch communityIdentifier {
                case let .id(id): moderatedCommunities.contains { $0.id == id }
                case let .actorId(actorId): moderatedCommunities.contains { $0.actorId == actorId }
                case let .community(community): moderatedCommunities.contains { $0.actorId == community.actorId }
                }
            }
        }
        return nil
    }
    
    /// Returns true if this person can perform moderator actions on the target person
    func canModerate(_ person: Person, in community: any Community3Providing) -> Bool {
        // admins can moderate anybody but a higher-ranking admin
        if isAdmin.value ?? false {
            if person.isAdmin.value ?? false {
                return api.isHigherAdmin(than: person)
            }
            return true
        }
        
        // if this person is not a mod, can't moderate
        guard let myModIndex = community.moderators.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        // if target is a mod, check that this person outranks them
        if let targetModIndex = community.moderators.firstIndex(where: { $0.id == person.id }) {
            return myModIndex < targetModIndex
        }
        
        // if target not a mod, can moderate
        return true
    }
}

// MARK: - Interactions

public extension Person {
    
    // Get Content
    
    func getContent(
        community: (any Community)? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person, posts: [Post], comments: [Comment]) {
        try await api.getContent(
            authorId: id,
            sort: sort,
            page: page,
            limit: limit,
            savedOnly: savedOnly,
            communityId: community?.id
        )
    }
    
    // MARK: Ban
    
    func ban(from community: any Community, removeContent: Bool, reason: String?, expires: Date?) async throws {
        try await api.banPersonFromCommunity(
            personId: id,
            communityId: community.id,
            ban: true,
            removeContent: removeContent,
            reason: reason,
            expires: expires
        )
    }
    
    func unban(from community: any Community, reason: String?) async throws {
        try await api.banPersonFromCommunity(
            personId: id,
            communityId: community.id,
            ban: false,
            removeContent: false,
            reason: reason
        )
    }
    
    // MARK: Purge
    
    func purge(reason: String?) async throws {
        try await api.purgePerson(id: id, reason: reason)
    }
    
    func banFromInstance(removeContent: Bool, reason: String?, expires: Date?) async throws {
        try await api.banPersonFromInstance(
            personId: id,
            ban: true,
            removeContent: removeContent,
            reason: reason,
            expires: expires
        )
    }
    
    func unbanFromInstance(reason: String?) async throws {
        try await api.banPersonFromInstance(
            personId: id,
            ban: false,
            removeContent: false,
            reason: reason,
            expires: nil
        )
    }
    
    // Note
    
    func updateNote(content: String?) {
        note = content
        
        Task {
            await updateQueue.addItem { properties in
                var properties = properties
                try await self.api.repository.editNote(id: self.id, content: content)
                properties.note = content
                return properties
            }
        }
    }
    
    // Profile
    
    // TODO: NOW
    
//    public func updateProfile(_ details: ProfileDetails) async throws {
//        let diff = ProfileDetailsMutation(
//            originalDetails: profileDetails(),
//            newDetails: details
//        )
//        if try await !(diff.isValid(forSoftware: api.software)) {
//            throw ApiClientError.invalidInput
//        }
//        try await api.editProfile(details)
//    }
    
    //    public func updateSettings(
    //        email: String? = nil,
    //        matrixId: String? = nil,
    //        showNsfw: Bool? = nil,
    //        blurNsfw: Bool? = nil,
    //        showBotAccounts: Bool? = nil,
    //        discussionLanguageIds: Set<Int>? = nil,
    //        sendNotificationsToEmail: Bool? = nil,
    //        isBot: Bool? = nil
    //    ) async throws {
    //        // iirc previous lemmy versions had issues with supplying `nil` for certain setting values.
    //        // I don't remember which versions this happened on or which parameters couldn't be `nil`.
    //        // Supplying them all to be safe.
    //        try await api.editAccountSettings(
    //            showNsfw: showNsfw ?? self.showNsfw,
    //            showScores: showScores,
    //            theme: theme,
    //            defaultListingType: defaultListingType,
    //            interfaceLanguage: interfaceLanguage,
    //            avatar: avatar?.absoluteString ?? "",
    //            banner: banner?.absoluteString ?? "",
    //            displayName: displayName,
    //            email: email ?? self.email,
    //            bio: description,
    //            matrixUserId: matrixId ?? self.matrixId,
    //            showAvatars: showAvatars,
    //            sendNotificationsToEmail: sendNotificationsToEmail ?? self.sendNotificationsToEmail,
    //            botAccount: isBot ?? self.isBot,
    //            showBotAccounts: showBotAccounts ?? self.showBotAccounts,
    //            showReadPosts: showReadPosts,
    //            discussionLanguages: discussionLanguageIds?.sorted(),
    //            openLinksInNewTab: openLinksInNewTab,
    //            blurNsfw: blurNsfw ?? self.blurNsfw,
    //            autoExpand: autoExpandImages,
    //            infiniteScrollEnabled: infiniteScrollEnabled,
    //            postListingMode: postListingMode,
    //            enableKeyboardNavigation: enableKeyboardNavigation,
    //            enableAnimatedImages: enableAnimatedImages,
    //            collapseBotComments: collapseBotComments,
    //            showUpvotes: nil,
    //            showDownvotes: nil,
    //            showUpvotePercentage: nil
    //        )
    //        self.email = email ?? self.email
    //        person1.matrixId = matrixId ?? self.matrixId
    //        self.showNsfw = showNsfw ?? self.showNsfw
    //        self.blurNsfw = blurNsfw ?? self.blurNsfw
    //        self.showBotAccounts = showBotAccounts ?? self.showBotAccounts
    //        self.discussionLanguageIds = discussionLanguageIds ?? self.discussionLanguageIds
    //        self.sendNotificationsToEmail = sendNotificationsToEmail ?? self.sendNotificationsToEmail
    //        person1.isBot = isBot ?? self.isBot
    //    }
}

public enum CommunityIdentifier {
    case id(Int)
    case actorId(ActorIdentifier)
    case community(any Community)
}

// MARK: Shim

public extension Person {
    func takeSnapshot1() -> Person1Snapshot {
        return .init(
            actorId: actorId,
            id: id,
            name: name,
            created: created,
            instanceId: instanceId,
            displayName: displayName,
            avatar: avatar,
            banner: banner,
            note: note,
            updated: updated,
            description: description,
            matrixUserId: matrixUserId,
            isBot: isBot,
            instanceBan: instanceBan,
            deleted: deleted,
            allPropertiesPresent: true
        )
    }
}
