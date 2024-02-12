//
//  User3.swift
//  Mlem
//
//  Created by Sjmarf on 11/02/2024.
//

import SwiftUI

protocol User3Providing: User2Providing {
    /// The instance that the user is registered on.
    var instance: InstanceCore1? { get }
    
    /// Is probably an array of Community1 instances. The array can occasionally also contain CommunityCore1 instances, if the community list was modified from the context of another instance since the User BaseModel was last refreshed. If this is the case, you might consider refreshing the user via the `.refresh()` method to update all of the communities.
    var moderatedCommunities: [any CommunityCore1Providing] { get }
}

@Observable
final class User3: User3Providing, BaseModel {
    // Conformance
    typealias APIType = GetPersonDetailsResponse
    typealias CommunityType = any CommunityCore1Providing
    var sourceInstance: NewInstanceStub
    
    // Wrapped layers
    let core3: UserCore3
    let base2: User2
    
    var cachedModeratedCommunities: [Community1] = .init()
    
    // Forwarded properties from UserBase2
    var id: Int { base2.id }
    var ban: BanType? { base2.ban }
    var isAdmin: Bool { base2.isAdmin }
    
    var actorId: URL { base2.actorId }
    var name: String { base2.name }
    var creationDate: Date { base2.creationDate }
    var updatedDate: Date? { base2.updatedDate }
    var displayName: String? { base2.displayName }
    var description: String? { base2.description }
    var matrixId: String? { base2.matrixId }
    var avatar: URL? { base2.avatar }
    var banner: URL? { base2.banner }
    var deleted: Bool { base2.deleted }
    var isBot: Bool { base2.isBot }
    
    var postCount: Int { base2.postCount }
    var postScore: Int { base2.postScore }
    var commentCount: Int { base2.commentCount }
    var commentScore: Int { base2.commentScore }
    
    // Forwarded properties from UserCore3
    var instance: InstanceCore1? { core3.instance }
    
    var moderatedCommunities: [any CommunityCore1Providing] {
        if cachedModeratedCommunities.hashValue == core3.moderatedCommunities.hashValue {
            return cachedModeratedCommunities
        }
        
        // Cached communities are outdated, so we need to merge with the core model to provide the best representation possible
        var communities: [any CommunityCore1Providing] = .init()
        for coreCommunity in core3.moderatedCommunities {
            if let baseCommunity = cachedModeratedCommunities.first(where: { coreCommunity.actorId == $0.actorId }) {
                communities.append(baseCommunity)
            } else {
                communities.append(coreCommunity)
            }
        }
        return communities
    }
    
    required init(sourceInstance: NewInstanceStub, from response: GetPersonDetailsResponse) {
        self.sourceInstance = sourceInstance
        self.core3 = UserCore3(from: response)
        self.base2 = sourceInstance.caches.user2.createModel(
            sourceInstance: sourceInstance,
            for: response.personView
        )
        self.update(with: response)
    }
    
    func update(with response: GetPersonDetailsResponse, cascade: Bool = true) {
        self.cachedModeratedCommunities = response.moderates.map {
            sourceInstance.caches.community1.createModel(sourceInstance: sourceInstance, for: $0.community )
        }
        if cascade {
            self.core3.update(with: response, cascade: false)
            self.base2.update(with: response.personView)
        }
    }
    
    static func getCache(for sourceInstance: NewInstanceStub) -> BaseContentCache<User3> {
        sourceInstance.caches.user3
    }
}
