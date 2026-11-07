//
//  RegistrationApplicationProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-31.
//

import Foundation

public struct RegistrationApplicationProperties: UnifiedPropertiesProviding {
    // From RegistrationApplicationSnapshot, guaranteed to always be present
    let id: Int
    let created: Date
    let questionResponse: String
    let email: String?
    let showNsfw: Bool
    let creator: Person
    var emailVerified: Bool
    var resolver: Person?
    var resolution: RegistrationApplication.ResolutionState
    
    @MainActor
    public init(api: ApiClient, snapshot: RegistrationApplicationSnapshot) {
        id = snapshot.id
        created = snapshot.created
        questionResponse = snapshot.questionResponse
        email = snapshot.email
        showNsfw = snapshot.showNsfw
        creator = api.caches.person.getModel(api: api, from: .person1(snapshot.creator))
        emailVerified = snapshot.emailVerified
        if let resolverSnapshot = snapshot.resolver {
            resolver = api.caches.person.getModel(api: api, from: .person1(resolverSnapshot))
        }
        resolution = snapshot.resolution
    }
    
    public mutating func merge(_ other: RegistrationApplicationProperties) {
        self.emailVerified = other.emailVerified
        self.resolver = other.resolver
        self.resolution = other.resolution
    }
}
