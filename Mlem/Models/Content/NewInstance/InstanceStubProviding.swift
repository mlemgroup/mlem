//
//  InstanceStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol InstanceStubProviding: ActorIdentifiable {
    var stub: NewInstanceStub { get }
    
    var url: URL { get }
    
    // From Instance1Providing. These are defined as nil in the extension below
    var id: Int? { get }
    var displayName: String? { get }
    var description: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var creationDate: Date? { get }
    var publicKey: String? { get }
    var lastRefreshDate: Date? { get }
}

extension InstanceStubProviding {
    var url: URL { stub.url }
    var actorId: URL { stub.actorId }
    
    var id: Int? { nil }
    var displayName: String? { nil }
    var description: String? { nil }
    var avatar: URL? { nil }
    var banner: URL? { nil }
    var creationDate: Date? { nil }
    var publicKey: String? { nil }
    var lastRefreshDate: Date? { nil }
}
