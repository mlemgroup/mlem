//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

protocol UserCore3Providing: UserCore2Providing {
    var instance: InstanceCore1? { get }
    var moderatedCommunities: [any CommunityCore1Providing] { get }
}

@Observable
final class UserCore3: UserCore3Providing, UserCore {
    typealias BaseEquivalent = UserBase3
    static var cache: CoreContentCache<UserCore3> = .init()
    typealias APIType = GetPersonDetailsResponse

    let core2: UserCore2

    var instance: InstanceCore1?
    var coreModeratedCommunities: [CommunityCore1] = .init()
    var moderatedCommunities: [any CommunityCore1Providing] { coreModeratedCommunities }
    
    // Forwarded properties from UserCore1
    var actorId: URL { core2.actorId }
    var name: String { core2.name }
    var creationDate: Date { core2.creationDate }
    var updatedDate: Date? { core2.updatedDate }
    var displayName: String? { core2.displayName }
    var description: String? { core2.description }
    var matrixId: String? { core2.matrixId }
    var avatar: URL? { core2.avatar }
    var banner: URL? { core2.banner }
    var deleted: Bool { core2.deleted }
    var isBot: Bool { core2.isBot }
    
    // Forwarded properties from UserCore2
    var postCount: Int { core2.postCount }
    var postScore: Int { core2.postScore }
    var commentCount: Int { core2.commentCount }
    var commentScore: Int { core2.commentScore }
    
    init(from response: GetPersonDetailsResponse) {
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }

        self.core2 = .create(from: response.personView)
        self.update(with: response, cascade: false)
    }
    
    func update(with response: GetPersonDetailsResponse, cascade: Bool = true) {
        self.coreModeratedCommunities = response.moderates.map { CommunityCore1.create(from: $0.community) }
        if cascade {
            self.core2.update(with: response.personView)
        }
    }
    
    var highestCachedTier: any UserCore1Providing { self }
}
