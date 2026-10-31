//
//  RegistrationApplication.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-31.
//

import Observation
import Foundation

@Observable
public class RegistrationApplication: UnifiedModelProviding {
    public typealias Properties = RegistrationApplicationProperties
    
    public var api: ApiClient
    private let properties: RegistrationApplicationProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<RegistrationApplication> = .init(parent: self, properties: properties)
    
    // MARK: API PRoperties
    // Properties that are provided by the API
    
    public let id: Int
    public let created: Date
    public let questionResponse: String
    public let email: String?
    public let showNsfw: Bool
    public let creator: Person
    public var emailVerified: Bool
    public var resolver: Person?
    public var resolution: DeprecatedRegistrationApplication.ResolutionState
    
    // MARK: Initializers and Updates
    
    public init(api: ApiClient, properties: RegistrationApplicationProperties) {
        self.api = api
        self.properties = properties
        
        self.id = properties.id
        self.created = properties.created
        self.questionResponse = properties.questionResponse
        self.email = properties.email
        self.showNsfw = properties.showNsfw
        self.creator = properties.creator
        self.emailVerified = properties.emailVerified
        self.resolver = properties.resolver
        self.resolution = properties.resolution
    }
    
    @MainActor
    public func update(with properties: RegistrationApplicationProperties) {
        setIfChanged(\.emailVerified, properties.emailVerified)
        setIfChanged(\.resolver, properties.resolver)
        setIfChanged(\.resolution, properties.resolution)
    }
    
    public func softUpdate(with properties: RegistrationApplicationProperties) {
        // noop - no higher-tier properties to update
    }
    
    public func fetchUpgraded() async throws -> RegistrationApplicationProperties {
        assertionFailure("Cannot upgrade RegistrationApplication")
        return self.properties
    }
    
    public func resolve(with api: ApiClient) async throws -> Self {
        assertionFailure("Cannot resolve RegistrationApplication")
        throw ApiClientError.invalidInput
    }
    
}
