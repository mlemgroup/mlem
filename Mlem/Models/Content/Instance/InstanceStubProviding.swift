//
//  InstanceStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol InstanceStubProviding: ActorIdentifiable, ApiSource {
    var stub: InstanceStub { get }
    
    var url: URL { get }
    
    // From Instance1Providing.
    var id_: Int? { get }
    var displayName_: String? { get }
    var description_: String? { get }
    var avatar_: URL? { get }
    var banner_: URL? { get }
    var creationDate_: Date? { get }
    var publicKey_: String? { get }
    var lastRefreshDate_: Date? { get }
    
    // From Instance3Providing.
    var version_: SiteVersion? { get }
}

extension InstanceStubProviding {
    var instance: InstanceStub { stub }
    var caches: BaseCacheGroup { stub.caches }
    var api: ApiClient { stub.api }
    
    var url: URL { stub.url }
    var actorId: URL { stub.actorId }
    
    var id_: Int? { nil }
    var displayName_: String? { nil }
    var description_: String? { nil }
    var avatar_: URL? { nil }
    var banner_: URL? { nil }
    var creationDate_: Date? { nil }
    var publicKey_: String? { nil }
    var lastRefreshDate_: Date? { nil }
    
    var version_: SiteVersion? { nil }
}

extension InstanceStubProviding {
    var host: String? { actorId.host() }
}
