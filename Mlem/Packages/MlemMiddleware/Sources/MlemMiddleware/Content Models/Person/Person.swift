//
//  Person.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Observation
import Foundation

@Observable
public final class Person:
    UnifiedModelProviding,
    Blockable,
    ContentIdentifiable,
    SelectableContentProviding,
    CommunityOrPerson,
    Resolvable,
    PurgableProviding,
    Sharable,
    FeedLoadable,
    Profile2Providing {
    // TODO: UnifiedCommunity, UnifiedInstance unify ProfileProviding
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
    public var instance: ExpectedValue<Instance>
    public var moderatedCommunities: ExpectedValue<[Community]>
    
    public var email: ExpectedValue<String?>
    public var showNsfw: ExpectedValue<Bool>
    public var theme: ExpectedValue<String>
    public var defaultListingType: ExpectedValue<ListingType>
    public var interfaceLanguage: ExpectedValue<String>
    public var showAvatars: ExpectedValue<Bool>
    public var sendNotificationsToEmail: ExpectedValue<Bool>
    public var showScores: ExpectedValue<Bool>
    public var showBotAccounts: ExpectedValue<Bool>
    public var showReadPosts: ExpectedValue<Bool>
    public var discussionLanguageIds: ExpectedValue<Set<Int>>
    public var emailVerified: ExpectedValue<Bool>
    public var acceptedApplication: ExpectedValue<Bool>
    public var openLinksInNewTab: ExpectedValue<Bool?>
    public var blurNsfw: ExpectedValue<Bool?>
    public var autoExpandImages: ExpectedValue<Bool?>
    public var infiniteScrollEnabled: ExpectedValue<Bool?>
    public var postListingMode: ExpectedValue<PostFeedViewMode?>
    public var totp2faEnabled: ExpectedValue<Bool?>
    public var enableKeyboardNavigation: ExpectedValue<Bool?>
    public var enableAnimatedImages: ExpectedValue<Bool?>
    public var collapseBotComments: ExpectedValue<Bool?>
    
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
        
        updateIfChanged(\.isAdmin.value_, properties.isAdmin)
        updateIfChanged(\.postCount.value_, properties.postCount)
        updateIfChanged(\.commentCount.value_, properties.commentCount)
        
        setIfNil(\.instance.value_, properties.instance)
        updateIfChanged(\.moderatedCommunities.value_, properties.moderatedCommunities)
        
        updateIfChanged(\.email.value_, properties.email)
        updateIfChanged(\.showNsfw.value_, properties.showNsfw)
        updateIfChanged(\.theme.value_, properties.theme)
        updateIfChanged(\.defaultListingType.value_, properties.defaultListingType)
        updateIfChanged(\.interfaceLanguage.value_, properties.interfaceLanguage)
        updateIfChanged(\.showAvatars.value_, properties.showAvatars)
        updateIfChanged(\.sendNotificationsToEmail.value_, properties.sendNotificationsToEmail)
        updateIfChanged(\.showScores.value_, properties.showScores)
        updateIfChanged(\.showBotAccounts.value_, properties.showBotAccounts)
        updateIfChanged(\.showReadPosts.value_, properties.showReadPosts)
        updateIfChanged(\.discussionLanguageIds.value_, properties.discussionLanguageIds)
        updateIfChanged(\.emailVerified.value_, properties.emailVerified)
        updateIfChanged(\.acceptedApplication.value_, properties.acceptedApplication)
        updateIfChanged(\.openLinksInNewTab.value_, properties.openLinksInNewTab)
        updateIfChanged(\.blurNsfw.value_, properties.blurNsfw)
        updateIfChanged(\.autoExpandImages.value_, properties.autoExpandImages)
        updateIfChanged(\.infiniteScrollEnabled.value_, properties.infiniteScrollEnabled)
        updateIfChanged(\.postListingMode.value_, properties.postListingMode)
        updateIfChanged(\.totp2faEnabled.value_, properties.totp2faEnabled)
        updateIfChanged(\.enableKeyboardNavigation.value_, properties.enableKeyboardNavigation)
        updateIfChanged(\.enableAnimatedImages.value_, properties.enableAnimatedImages)
        updateIfChanged(\.collapseBotComments.value_, properties.collapseBotComments)
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
    
    public func resolve(with api: ApiClient) async throws -> Self {
        let stub = PersonStub(api: api, url: allResolvableUrls[0])
        return try await stub.getPerson() as! Self
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
    
    func isBannedFromCommunity(_ community: Community) -> Bool? {
        isBannedFromCommunity(id: community.id)
    }
    
    func profileDetails() -> ProfileDetails {
        .init(
            avatar: avatar,
            banner: banner,
            displayName: displayName,
            description: description,
            matrixUserId: matrixUserId
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
    func canModerate(_ person: Person, communityModerators: [Person]) -> Bool {
        // admins can moderate anybody but a higher-ranking admin
        if isAdmin.value ?? false {
            if person.isAdmin.value ?? false {
                return api.isHigherAdmin(than: person)
            }
            return true
        }
        
        // if this person is not a mod, can't moderate
        guard let myModIndex = communityModerators.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        // if target is a mod, check that this person outranks them
        if let targetModIndex = communityModerators.firstIndex(where: { $0.id == person.id }) {
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
        community: Community? = nil,
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
    
    func ban(from community: Community, removeContent: Bool, reason: String?, expires: Date?) async throws {
        try await api.banPersonFromCommunity(
            personId: id,
            communityId: community.id,
            ban: true,
            removeContent: removeContent,
            reason: reason,
            expires: expires
        )
    }
    
    func unban(from community: Community, reason: String?) async throws {
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
    
    // TODO: NOW make a User concept?
    
    func updateProfile(_ details: ProfileDetails) async throws {
        let diff = ProfileDetailsMutation(
            originalDetails: profileDetails(),
            newDetails: details
        )
        if try await !(diff.isValid(forSoftware: api.software)) {
            throw ApiClientError.invalidInput
        }
        
        avatar = details.avatar
        banner = details.banner
        displayName = details.displayName ?? displayName
        description = details.description
        matrixUserId = details.matrixUserId
        
        await updateQueue.addItem { properties in
            try await self.api.editProfile(details)
            
            var properties = properties
            properties.avatar = details.avatar
            properties.banner = details.banner
            properties.displayName = details.displayName ?? properties.displayName
            properties.description = details.description
            properties.matrixUserId = details.matrixUserId
            return properties
        }
    }
    
    struct ProfileSettings {
        let email: String?
        let matrixUserId: String?
        let showNsfw: Bool?
        let blurNsfw: Bool?
        let showBotAccounts: Bool?
        let discussionLanguageIds: Set<Int>?
        let sendNotificationsToEmail: Bool?
        let isBot: Bool?
        
        public init(
            email: String? = nil,
            matrixUserId: String? = nil,
            showNsfw: Bool? = nil,
            blurNsfw: Bool? = nil,
            showBotAccounts: Bool? = nil,
            discussionLanguageIds: Set<Int>? = nil,
            sendNotificationsToEmail: Bool? = nil,
            isBot: Bool? = nil,
        ) {
            self.email = email
            self.matrixUserId = matrixUserId
            self.showNsfw = showNsfw
            self.blurNsfw = blurNsfw
            self.showBotAccounts = showBotAccounts
            self.discussionLanguageIds = discussionLanguageIds
            self.sendNotificationsToEmail = sendNotificationsToEmail
            self.isBot = isBot
        }
    }
    
    var updateSettings: ((ProfileSettings) async throws -> Void)? {
        if let showNsfw = self.showNsfw.value,
           let showScores = self.showScores.value,
           let theme = self.theme.value,
           let defaultListingType = self.defaultListingType.value,
           let interfaceLanguage = self.interfaceLanguage.value,
           let email = self.email.value,
           let showAvatars = self.showAvatars.value,
           let sendNotificationsToEmail = self.sendNotificationsToEmail.value,
           let showBotAccounts = self.showBotAccounts.value,
           let showReadPosts = self.showReadPosts.value,
           let discussionLanguages = self.discussionLanguageIds.value,
           let openLinksInNewTab = self.openLinksInNewTab.value,
           let blurNsfw = self.blurNsfw.value,
           let autoExpandImages = self.autoExpandImages.value,
           let infiniteScrollEnabled = self.infiniteScrollEnabled.value,
           let postListingMode = self.postListingMode.value,
           let enableKeyboardNavigation = self.enableKeyboardNavigation.value,
           let enableAnimatedImages = self.enableAnimatedImages.value,
           let collapseBotComments = self.collapseBotComments.value {
            return { profileSettings in
                await self.updateQueue.addItem { properties in
                    // this function has some untidy source-of-truth behavior--canonically we want to use the provided properties from the UpdateQueue,
                    // but those are not guaranteed to have user-tier fields so we fall back on the guaranteed values from the `if let` wall above.
                    // note also that a `nil` in `ProfileSettings` indicates no change
                    let newEmail: String? = profileSettings.email ?? properties.email ?? email
                    let newMatrixUserId: String? = profileSettings.matrixUserId ?? properties.matrixUserId
                    let newShowNsfw: Bool = profileSettings.showNsfw ?? properties.showNsfw ?? showNsfw
                    let newShowBotAccounts: Bool = profileSettings.showBotAccounts ?? properties.showBotAccounts ?? showBotAccounts
                    let newDiscussionLanguageIds: Set<Int> = (profileSettings.discussionLanguageIds ?? properties.discussionLanguageIds ?? discussionLanguages)
                    let newSendNotificationsToEmail: Bool = profileSettings.sendNotificationsToEmail ?? properties.sendNotificationsToEmail ?? sendNotificationsToEmail
                    let newIsBot: Bool = profileSettings.isBot ?? properties.isBot
                    
                    try await self.api.editAccountSettings(
                        showNsfw: newShowNsfw,
                        showScores: properties.showScores ?? showScores,
                        theme: properties.theme ?? theme,
                        defaultListingType: properties.defaultListingType ?? defaultListingType,
                        interfaceLanguage: properties.interfaceLanguage ?? interfaceLanguage,
                        avatar: properties.avatar?.absoluteString ?? "",
                        banner: properties.banner?.absoluteString ?? "",
                        displayName: properties.displayName,
                        email: newEmail,
                        bio: properties.description,
                        matrixUserId: newMatrixUserId,
                        showAvatars: properties.showAvatars ?? showAvatars,
                        sendNotificationsToEmail: newSendNotificationsToEmail,
                        botAccount: newIsBot,
                        showBotAccounts: newShowBotAccounts,
                        showReadPosts: properties.showReadPosts ?? showReadPosts,
                        discussionLanguages: newDiscussionLanguageIds.sorted(),
                        openLinksInNewTab: properties.openLinksInNewTab ?? openLinksInNewTab,
                        blurNsfw: profileSettings.blurNsfw ?? (properties.blurNsfw as? Bool) ?? blurNsfw,
                        autoExpand: properties.autoExpandImages ?? autoExpandImages,
                        infiniteScrollEnabled: properties.infiniteScrollEnabled ?? infiniteScrollEnabled,
                        postListingMode: properties.postListingMode ?? postListingMode,
                        enableKeyboardNavigation: properties.enableKeyboardNavigation ?? enableKeyboardNavigation,
                        enableAnimatedImages: properties.enableAnimatedImages ?? enableAnimatedImages,
                        collapseBotComments: properties.collapseBotComments ?? collapseBotComments,
                        showUpvotes: nil,
                        showDownvotes: nil,
                        showUpvotePercentage: nil
                    )
                    
                    var properties = properties
                    properties.email = newEmail
                    properties.matrixUserId = newMatrixUserId
                    properties.showNsfw = newShowNsfw
                    properties.showBotAccounts = newShowBotAccounts
                    properties.discussionLanguageIds = newDiscussionLanguageIds
                    properties.sendNotificationsToEmail = newSendNotificationsToEmail
                    properties.isBot = newIsBot
                    return properties
                }
            }
        }
        return nil
    }
}

public enum CommunityIdentifier {
    case id(Int)
    case actorId(ActorIdentifier)
    case community(Community)
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

public extension Person {
    var displayName_: String? { displayName }
    var description_: String? { description }
    var banner_: URL? { banner }
    var created_: Date? { created }
    var updated_: Date? { updated }
}
