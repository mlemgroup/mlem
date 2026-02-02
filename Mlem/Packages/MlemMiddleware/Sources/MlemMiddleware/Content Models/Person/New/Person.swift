//
//  Person.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Observation
import Foundation

@Observable
public class Person: UnifiedModelProviding {
    public static var tierNumber: Int
    
    public typealias Properties = PersonProperties
    
    public var api: ApiClient
    private let properties: PersonProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Person> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
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
    public var site: ExpectedValue<(any Instance)>
    public var moderatedCommunities: ExpectedValue<[any Community]>
    
    public init(api: ApiClient, properties: PersonProperties) {
        
    }
    
    // MARK: Upgrades
    
    public func update(with properties: PersonProperties) {
        <#code#>
    }
    
    public func softUpdate(with properties: PersonProperties) {
        <#code#>
    }
    
    public func fetchUpgraded() async throws -> PersonProperties {
        <#code#>
    }
}

