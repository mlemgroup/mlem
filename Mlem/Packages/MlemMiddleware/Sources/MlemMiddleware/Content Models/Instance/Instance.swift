//
//  Instance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-03-13.
//

import Observation
import Foundation

@Observable
public class Instance:
    UnifiedModelProviding,
    ActorIdentifiable
{
    public typealias Properties = InstanceProperties
    
    public var api: ApiClient
    private let properties: InstanceProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Instance> = .init(parent: self, properties: properties)
    
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
    
    public func refresh() async throws {
        try await updateQueue.refresh()
    }
    
    public func fetchUpgraded() async throws -> InstanceProperties {
        let externalApi: ApiClient = apiIsLocal ? api : .getApiClient(url: actorId.url, username: nil)
        let snapshot = try await externalApi.repository.getMyInstance()
        return await .init(api: api, snapshot: .instance3(snapshot))
    }
    
    public func resolve(with api: ApiClient) async throws -> Self {
        // TODO: NOW
        return self
    }
    
}
