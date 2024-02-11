//
//  Community1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import SwiftUI

protocol Community1Providing: CommunityCore1Providing {
    var id: Int { get }
    func highestCachedTier() -> any Community1Providing
}

typealias Community = Community1Providing

@Observable
final class Community1: Community1Providing, BaseModel {
    // Conformance
    typealias APIType = APICommunity
    var sourceInstance: NewInstanceStub
    
    // Wrapped layers
    let core1: CommunityCore1
    
    let id: Int
    
    // Forwarded properties from CommunityCore1
    var actorId: URL { core1.actorId }
    var name: String { core1.name }
    var creationDate: Date { core1.creationDate }
    var updatedDate: Date? { core1.updatedDate }
    var displayName: String { core1.displayName }
    var description: String? { core1.description }
    var removed: Bool { core1.removed }
    var deleted: Bool { core1.deleted }
    var nsfw: Bool { core1.nsfw }
    var avatar: URL? { core1.avatar }
    var banner: URL? { core1.banner }
    var hidden: Bool { core1.hidden }
    var onlyModeratorsCanPost: Bool { core1.onlyModeratorsCanPost }
    
    required init(sourceInstance: NewInstanceStub, from community: APICommunity) {
        self.sourceInstance = sourceInstance
        self.core1 = CommunityCore1.create(from: community)
        
        self.id = community.id
    }
    
    func update(with community: APICommunity, cascade: Bool = true) {
        if cascade {
            core1.update(with: community)
        }
    }
    
    func highestCachedTier() -> any Community1Providing {
        return sourceInstance.caches.community2.retrieveModel(id: id) ?? self
    }
    
    static func getCache(for sourceInstance: NewInstanceStub) -> BaseContentCache<Community1> {
        return sourceInstance.caches.community1
    }
}
