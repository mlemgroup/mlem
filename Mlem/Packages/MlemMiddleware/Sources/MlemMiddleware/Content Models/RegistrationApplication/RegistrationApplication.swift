//
//  RegistrationApplication.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-31.
//

import Observation
import Foundation

@Observable
public class RegistrationApplication: UnifiedModelProviding, ContentIdentifiable, FeedLoadable {
    public typealias Properties = RegistrationApplicationProperties
    
    public var api: ApiClient
    private let properties: RegistrationApplicationProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<RegistrationApplication> = .init(parent: self, properties: properties)
    
    // MARK: API Properties
    // Properties that are provided by the API
    
    public let id: Int
    public let created: Date
    public let questionResponse: String
    public let email: String?
    public let showNsfw: Bool
    public let creator: Person
    public var emailVerified: Bool
    public var resolver: Person?
    public var resolution: RegistrationApplication.ResolutionState
    
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

// MARK: - Computed

public extension RegistrationApplication {
    var modMailId: Int {
        var hasher: Hasher = .init()
        hasher.combine("application")
        hasher.combine(id)
        return hasher.finalize()
    }
}

// MARK: - Interactions

public extension RegistrationApplication {
    
    func approve(callback: ((UpdateStatus) -> Void)? = nil) {
        self.resolution = .approved
        api.unreadCount?.updateUnverifiedItem(itemType: .moderation, isRead: true)
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.approveRegistrationApplication(id: self.id)
                    self.api.unreadCount?.verifyItem(itemType: .moderation, isRead: true)
                    callback?(.success)
                    return await .init(api: self.api, snapshot: snapshot)
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
    
    func deny(reason: String?, callback: ((UpdateStatus) -> Void)?) {
        self.resolution = .denied(reason: reason)
        api.unreadCount?.updateUnverifiedItem(itemType: .moderation, isRead: true)
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.denyRegistrationApplication(id: self.id, reason: reason)
                    self.api.unreadCount?.verifyItem(itemType: .moderation, isRead: true)
                    callback?(.success)
                    return await .init(api: self.api, snapshot: snapshot)
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
}

public extension RegistrationApplication {
    enum ResolutionState: Equatable {
        case unresolved, approved, denied(reason: String?)
        
        public var reason: String? {
            switch self {
            case .unresolved: nil
            case .approved: nil
            case let .denied(reason): reason
            }
        }
        
        public var isDenied: Bool {
            switch self {
            case .denied: true
            default: false
            }
        }
    }
}
