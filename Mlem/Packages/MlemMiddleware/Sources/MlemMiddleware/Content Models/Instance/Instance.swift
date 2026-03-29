//
//  Instance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-03-13.
//

import Observation
import Foundation

// TODO: NOW sharable, blockable

@Observable
public final class Instance:
    UnifiedModelProviding,
    ActorIdentifiable,
    Blockable,
    Profile2Providing,
    ContentIdentifiable
{
    public typealias Properties = InstanceProperties
    
    public var api: ApiClient
    private let properties: InstanceProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Instance> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
    public var blocked: Bool
    
    /// If this is `false`, The instance is *not* guaranteed to be non-local, particularly for locally running instances.
    public var local: Bool = false
    
    // MARK: API Properties
    // Properties that are provided by the API
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let instanceId: Int
    public let created: Date
    public let updated: Date?
    public let publicKey: String
    public var displayName: String
    public var description: String?
    public var shortDescription: String?
    public var avatar: URL?
    public var banner: URL?
    public var lastRefresh: Date
    public var contentWarning: String?
    
    public var setup: ExpectedValue<Bool>
    public var voteFederationMode: ExpectedValue<VoteFederationMode>
    public var nsfwContentEnabled: ExpectedValue<Bool>
    public var communityCreationRestrictedToAdmins: ExpectedValue<Bool>
    public var emailVerificationRequired: ExpectedValue<Bool>
    public var applicationQuestion: ExpectedValue<String?>
    public var isPrivate: ExpectedValue<Bool>
    public var defaultTheme: ExpectedValue<String>
    public var defaultFeed: ExpectedValue<ListingType>
    public var legalInformation: ExpectedValue<String?>
    public var hideModlogNames: ExpectedValue<Bool>
    public var emailApplicationsToAdmins: ExpectedValue<Bool>
    public var emailReportsToAdmins: ExpectedValue<Bool>
    public var slurFilterRegex: ExpectedValue<String?>
    public var actorNameMaxLength: ExpectedValue<Int>
    public var federationEnabled: ExpectedValue<Bool>
    public var captchaEnabled: ExpectedValue<Bool>
    public var captchaDifficulty: ExpectedValue<CaptchaDifficulty?>
    public var registrationMode: ExpectedValue<RegistrationMode>
    public var federationSignedFetch: ExpectedValue<Bool?>
    public var defaultPostListingMode: ExpectedValue<PostFeedViewMode?>
    public var defaultPostSortType: ExpectedValue<PostSortType?>
    public var userCount: ExpectedValue<Int>
    public var postCount: ExpectedValue<Int>
    public var commentCount: ExpectedValue<Int>
    public var communityCount: ExpectedValue<Int>
    public var activeUserCount: ExpectedValue<ActiveUserCount>
    
    public var allLanguages: ExpectedValue<[Locale.Language]>
    public var software: ExpectedValue<SiteSoftware>
    public var allowedLanguageIds: ExpectedValue<Set<Int>>
    public var blockedUrls: ExpectedValue<[InstanceUrlBlockRecord]?>
    public var administrators: ExpectedValue<[Person]>
    
    public init(api: ApiClient, properties: InstanceProperties) {
        self.api = api
        self.properties = properties
        self.blocked = api.blocks?.instances.keys.contains(properties.actorId) ?? false
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.instanceId = properties.instanceId
        self.created = properties.created
        self.updated = properties.updated
        self.publicKey = properties.publicKey
        self.displayName = properties.displayName
        self.description = properties.description
        self.shortDescription = properties.shortDescription
        self.avatar = properties.avatar
        self.banner = properties.banner
        self.lastRefresh = properties.lastRefresh
        self.contentWarning = properties.contentWarning
        
        // because upgrade() is not available until all properties are initialized, first populate all properties
        // with ExpectedValues that don't actually do anything, then reassign them properly at the end of the init
        // this is somewhat cumbersome but avoids lazy vars, which are very awkward in Observables
        self.setup = dummyExpectedValue(properties.setup)
        self.voteFederationMode = dummyExpectedValue(properties.voteFederationMode)
        self.nsfwContentEnabled = dummyExpectedValue(properties.nsfwContentEnabled)
        self.communityCreationRestrictedToAdmins = dummyExpectedValue(properties.communityCreationRestrictedToAdmins)
        self.emailVerificationRequired = dummyExpectedValue(properties.emailVerificationRequired)
        self.applicationQuestion = dummyExpectedValue(properties.applicationQuestion)
        self.isPrivate = dummyExpectedValue(properties.isPrivate)
        self.defaultTheme = dummyExpectedValue(properties.defaultTheme)
        self.defaultFeed = dummyExpectedValue(properties.defaultFeed)
        self.legalInformation = dummyExpectedValue(properties.legalInformation)
        self.hideModlogNames = dummyExpectedValue(properties.hideModlogNames)
        self.emailApplicationsToAdmins = dummyExpectedValue(properties.emailApplicationsToAdmins)
        self.emailReportsToAdmins = dummyExpectedValue(properties.emailReportsToAdmins)
        self.slurFilterRegex = dummyExpectedValue(properties.slurFilterRegex)
        self.actorNameMaxLength = dummyExpectedValue(properties.actorNameMaxLength)
        self.federationEnabled = dummyExpectedValue(properties.federationEnabled)
        self.captchaEnabled = dummyExpectedValue(properties.captchaEnabled)
        self.captchaDifficulty = dummyExpectedValue(properties.captchaDifficulty)
        self.registrationMode = dummyExpectedValue(properties.registrationMode)
        self.federationSignedFetch = dummyExpectedValue(properties.federationSignedFetch)
        self.defaultPostListingMode = dummyExpectedValue(properties.defaultPostListingMode)
        self.defaultPostSortType = dummyExpectedValue(properties.defaultPostSortType)
        self.userCount = dummyExpectedValue(properties.userCount)
        self.postCount = dummyExpectedValue(properties.postCount)
        self.commentCount = dummyExpectedValue(properties.commentCount)
        self.communityCount = dummyExpectedValue(properties.communityCount)
        self.activeUserCount = dummyExpectedValue(properties.activeUserCount)
        self.allLanguages = dummyExpectedValue(properties.allLanguages)
        self.software = dummyExpectedValue(properties.software)
        self.allowedLanguageIds = dummyExpectedValue(properties.allowedLanguageIds)
        self.blockedUrls = dummyExpectedValue(properties.blockedUrls)
        self.administrators = dummyExpectedValue(properties.administrators)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() }
            )
        }
        self.setup = expectedValue(properties.setup)
        self.voteFederationMode = expectedValue(properties.voteFederationMode)
        self.nsfwContentEnabled = expectedValue(properties.nsfwContentEnabled)
        self.communityCreationRestrictedToAdmins = expectedValue(properties.communityCreationRestrictedToAdmins)
        self.emailVerificationRequired = expectedValue(properties.emailVerificationRequired)
        self.applicationQuestion = expectedValue(properties.applicationQuestion)
        self.isPrivate = expectedValue(properties.isPrivate)
        self.defaultTheme = expectedValue(properties.defaultTheme)
        self.defaultFeed = expectedValue(properties.defaultFeed)
        self.legalInformation = expectedValue(properties.legalInformation)
        self.hideModlogNames = expectedValue(properties.hideModlogNames)
        self.emailApplicationsToAdmins = expectedValue(properties.emailApplicationsToAdmins)
        self.emailReportsToAdmins = expectedValue(properties.emailReportsToAdmins)
        self.slurFilterRegex = expectedValue(properties.slurFilterRegex)
        self.actorNameMaxLength = expectedValue(properties.actorNameMaxLength)
        self.federationEnabled = expectedValue(properties.federationEnabled)
        self.captchaEnabled = expectedValue(properties.captchaEnabled)
        self.captchaDifficulty = expectedValue(properties.captchaDifficulty)
        self.registrationMode = expectedValue(properties.registrationMode)
        self.federationSignedFetch = expectedValue(properties.federationSignedFetch)
        self.defaultPostListingMode = expectedValue(properties.defaultPostListingMode)
        self.defaultPostSortType = expectedValue(properties.defaultPostSortType)
        self.userCount = expectedValue(properties.userCount)
        self.postCount = expectedValue(properties.postCount)
        self.commentCount = expectedValue(properties.commentCount)
        self.communityCount = expectedValue(properties.communityCount)
        self.activeUserCount = expectedValue(properties.activeUserCount)
        
        self.allLanguages = expectedValue(properties.allLanguages)
        self.software = expectedValue(properties.software)
        self.allowedLanguageIds = expectedValue(properties.allowedLanguageIds)
        self.blockedUrls = expectedValue(properties.blockedUrls)
        self.administrators = expectedValue(properties.administrators)
    }
    
    @MainActor
    public func update(with properties: InstanceProperties) {
        setIfChanged(\.displayName, properties.displayName)
        setIfChanged(\.description, properties.description)
        setIfChanged(\.shortDescription, properties.shortDescription)
        setIfChanged(\.avatar, properties.avatar)
        setIfChanged(\.banner, properties.banner)
        setIfChanged(\.lastRefresh, properties.lastRefresh)
        setIfChanged(\.contentWarning, properties.contentWarning)
        
        updateIfChanged(\.setup.value_, properties.setup)
        updateIfChanged(\.voteFederationMode.value_, properties.voteFederationMode)
        updateIfChanged(\.nsfwContentEnabled.value_, properties.nsfwContentEnabled)
        updateIfChanged(\.communityCreationRestrictedToAdmins.value_, properties.communityCreationRestrictedToAdmins)
        updateIfChanged(\.emailVerificationRequired.value_, properties.emailVerificationRequired)
        updateIfChanged(\.applicationQuestion.value_, properties.applicationQuestion)
        updateIfChanged(\.isPrivate.value_, properties.isPrivate)
        updateIfChanged(\.defaultTheme.value_, properties.defaultTheme)
        updateIfChanged(\.defaultFeed.value_, properties.defaultFeed)
        updateIfChanged(\.legalInformation.value_, properties.legalInformation)
        updateIfChanged(\.hideModlogNames.value_, properties.hideModlogNames)
        updateIfChanged(\.emailApplicationsToAdmins.value_, properties.emailApplicationsToAdmins)
        updateIfChanged(\.emailReportsToAdmins.value_, properties.emailReportsToAdmins)
        updateIfChanged(\.slurFilterRegex.value_, properties.slurFilterRegex)
        updateIfChanged(\.actorNameMaxLength.value_, properties.actorNameMaxLength)
        updateIfChanged(\.federationEnabled.value_, properties.federationEnabled)
        updateIfChanged(\.captchaEnabled.value_, properties.captchaEnabled)
        updateIfChanged(\.captchaDifficulty.value_, properties.captchaDifficulty)
        updateIfChanged(\.registrationMode.value_, properties.registrationMode)
        updateIfChanged(\.federationSignedFetch.value_, properties.federationSignedFetch)
        updateIfChanged(\.defaultPostListingMode.value_, properties.defaultPostListingMode)
        updateIfChanged(\.defaultPostSortType.value_, properties.defaultPostSortType)
        updateIfChanged(\.userCount.value_, properties.userCount)
        updateIfChanged(\.postCount.value_, properties.postCount)
        updateIfChanged(\.commentCount.value_, properties.commentCount)
        updateIfChanged(\.communityCount.value_, properties.communityCount)
        updateIfChanged(\.activeUserCount.value_, properties.activeUserCount)
        
        setIfNil(\.allLanguages.value_, properties.allLanguages) // not expected to change
        updateIfChanged(\.software.value_, properties.software)
        updateIfChanged(\.allowedLanguageIds.value_, properties.allowedLanguageIds)
        updateIfChanged(\.blockedUrls.value_, properties.blockedUrls)
        updateIfChanged(\.administrators.value_, properties.administrators)
    }
    
    @MainActor
    public func softUpdate(with properties: InstanceProperties) {
        setIfNil(\.setup.value_, properties.setup)
        setIfNil(\.voteFederationMode.value_, properties.voteFederationMode)
        setIfNil(\.nsfwContentEnabled.value_, properties.nsfwContentEnabled)
        setIfNil(\.communityCreationRestrictedToAdmins.value_, properties.communityCreationRestrictedToAdmins)
        setIfNil(\.emailVerificationRequired.value_, properties.emailVerificationRequired)
        setIfNil(\.applicationQuestion.value_, properties.applicationQuestion)
        setIfNil(\.isPrivate.value_, properties.isPrivate)
        setIfNil(\.defaultTheme.value_, properties.defaultTheme)
        setIfNil(\.defaultFeed.value_, properties.defaultFeed)
        setIfNil(\.legalInformation.value_, properties.legalInformation)
        setIfNil(\.hideModlogNames.value_, properties.hideModlogNames)
        setIfNil(\.emailApplicationsToAdmins.value_, properties.emailApplicationsToAdmins)
        setIfNil(\.emailReportsToAdmins.value_, properties.emailReportsToAdmins)
        setIfNil(\.slurFilterRegex.value_, properties.slurFilterRegex)
        setIfNil(\.actorNameMaxLength.value_, properties.actorNameMaxLength)
        setIfNil(\.federationEnabled.value_, properties.federationEnabled)
        setIfNil(\.captchaEnabled.value_, properties.captchaEnabled)
        setIfNil(\.captchaDifficulty.value_, properties.captchaDifficulty)
        setIfNil(\.registrationMode.value_, properties.registrationMode)
        setIfNil(\.federationSignedFetch.value_, properties.federationSignedFetch)
        setIfNil(\.defaultPostListingMode.value_, properties.defaultPostListingMode)
        setIfNil(\.defaultPostSortType.value_, properties.defaultPostSortType)
        setIfNil(\.userCount.value_, properties.userCount)
        setIfNil(\.postCount.value_, properties.postCount)
        setIfNil(\.commentCount.value_, properties.commentCount)
        setIfNil(\.communityCount.value_, properties.communityCount)
        setIfNil(\.activeUserCount.value_, properties.activeUserCount)
        setIfNil(\.software.value_, properties.software)
        setIfNil(\.allowedLanguageIds.value_, properties.allowedLanguageIds)
        setIfNil(\.blockedUrls.value_, properties.blockedUrls)
        setIfNil(\.administrators.value_, properties.administrators)
    }
    
    // MARK: Upgrades
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    /// Gets this instance using the ApiClient local to this instance
    public func getLocal() async throws -> Instance {
        if apiIsLocal { return self }
        
        let localApi = ApiClient.getApiClient(url: actorId.hostUrl, username: nil)
        return try await localApi.getMyInstance()
    }
    
    public func refresh() async throws {
        try await updateQueue.refresh()
    }
    
    public func fetchUpgraded() async throws -> InstanceProperties {
        let externalApi: ApiClient = apiIsLocal ? api : .getApiClient(url: actorId.url, username: nil)
        let snapshot = try await externalApi.repository.getMyInstance()
        return await .init(api: api, snapshot: .instance3(snapshot))
    }
    
    public func resolve(with api: ApiClient) async throws -> Instance {
        guard let instance = try await api.getCommunityOfInstance(actorId: actorId).instance.value as? Instance else {
            throw InstanceUpgradeError.noSiteReturned
        }
        return instance
    }
    
}

// MARK: Computed

public extension Instance {
    @inlinable
    var name: String { host }
    
    func language(withId id: Int) -> Locale.Language? {
        guard let allLanguages = allLanguages.value else { return nil }
        return allLanguages[safeIndex: id - 1]
    }
    
    func getLanguageId(for language: Locale.Language) -> Int? {
        guard let allLanguages = allLanguages.value else { return nil }
        return allLanguages.firstIndex(of: language)?.advanced(by: 1)
    }
    
    func languages(withIds ids: Set<Int>) -> [Locale.Language] {
        ids.lazy.sorted(by: <).compactMap { self.language(withId: $0) }
    }
    
    var allowedLanguages: Set<Locale.Language>? {
        guard let allowedLanguageIds = allowedLanguageIds.value else { return nil }
        return Set(allowedLanguageIds.lazy.compactMap { self.language(withId: $0) })
    }
    
    var guestApi: ApiClient {
        .getApiClient(url: local ? api.baseUrl : actorId.hostUrl, username: nil)
    }
}

// MARK: Interactions

public extension Instance {
    
    // Add Admin
    
    func addAdmin(personId: Int, added: Bool) {
        Task {
            await updateQueue.addItem { properties in
                let snapshots = try await self.api.repository.addAdmin(personId: personId, added: added)
                let updatedAdministrators = await self.api.caches.person.getModels(api: self.api, from: snapshots.map { .person2($0) })
                
                // update person's admin status
                // only need to do this manually if removing admin, otherwise handled by above caching logic
                if !added, let person = self.api.caches.person.retrieveModel(cacheId: personId) {
                    person.isAdmin.value_ = false
                }
                
                var properties = properties
                properties.administrators = updatedAdministrators
                return properties
            }
        }
    }
    
    // Username Validity
    
    var usernameIsValidForNewAccount: ((String) async throws -> UsernameValidity)? {
        if let actorNameMaxLength = actorNameMaxLength.value {
            return { try await self.usernameIsValidForNewAccount($0, actorNameMaxLength: actorNameMaxLength) }
        }
        return nil
    }
    
    private func usernameIsValidForNewAccount(_ username: String, actorNameMaxLength: Int) async throws -> UsernameValidity {
        guard username.count >= 3 else {
            return .invalid(.tooShort(minLength: 3))
        }
        guard username.count <= actorNameMaxLength else {
            return .invalid(.tooLong(maxLength: actorNameMaxLength))
        }
        
        // Relevant backend code https://github.com/LemmyNet/lemmy/blob/5095092d3a6b0c194295e2cf3034d2b9abf8db54/crates/utils/src/utils/validation.rs#L94
        
        let regex = /^(?:[a-zA-Z0-9_]+|[0-9_\p{Arabic}]+|[0-9_\p{Cyrillic}]+)$/
        
        if try regex.wholeMatch(in: username) == nil {
            // If username isn't english, give a generic error
            let englishRegex = /[^\p{Arabic}\p{Cyrillic}]+/
            if try englishRegex.wholeMatch(in: username) == nil { return .invalid(.other) }
            
            // If the username *is* in english, we can be more descriptive
            let invalidCharacters = username.filter { char in
                if char == "_" { return false }
                guard let scalar = char.unicodeScalars.first, char.unicodeScalars.count == 1 else { return true }
                if scalar.value >= 65, scalar.value <= 90 { return false } // Uppercase
                if scalar.value >= 97, scalar.value <= 122 { return false } // Lowercase
                if scalar.value >= 48, scalar.value <= 57 { return false } // Numbers
                return true
            }
            
            if !invalidCharacters.isEmpty {
                return .invalid(.containsInvalidCharacters(Set(invalidCharacters)))
            }
            
            assertionFailure()
            return .invalid(.other)
        }
        
        do {
            _ = try await api.getPerson(username: username)
            return .taken
        } catch ApiClientError.noEntityFound {
            return .available
        }
    }
}
