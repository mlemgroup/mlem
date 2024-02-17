//
//  UserStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

let developerNames = [
    "https://lemmy.tespia.org/u/navi",
    "https://beehaw.org/u/jojo",
    "https://beehaw.org/u/kronusdark",
    "https://lemmy.ml/u/ericbandrews",
    "https://programming.dev/u/tht7",
    "https://lemmy.ml/u/sjmarf"
]

protocol PersonStubProviding: CommunityOrPersonStub {    
    // From User1Providing. These are defined as nil in the extension below
    var id: Int? { get }
    var creationDate: Date? { get }
    var updatedDate: Date? { get }
    var displayName: String? { get }
    var description: String? { get }
    var matrixId: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var deleted: Bool? { get }
    var isBot: Bool? { get }
    var instanceBan: InstanceBanType? { get }
    var blocked: Bool? { get }
    
    // From User2Providing. These are defined as nil in the extension below
    var postCount: Int? { get }
    var postScore: Int? { get }
    var commentCount: Int? { get }
    var commentScore: Int? { get }
    
    // From User3Providing. These are defined as nil in the extension below
    var instance: Instance1? { get }
    var moderatedCommunities: [Community1]? { get }
    
    func getFlairs(postContext: (any Post)?, communityContext: (any Community)?) -> [PersonFlair]
}

extension PersonStubProviding {
    static var identifierPrefix: String { "@" }
    
    var id: Int? { nil }
    var creationDate: Date? { nil }
    var updatedDate: Date? { nil }
    var displayName: String? { nil }
    var description: String? { nil }
    var matrixId: String? { nil }
    var avatar: URL? { nil }
    var banner: URL? { nil }
    var deleted: Bool? { nil }
    var isBot: Bool? { nil }
    var instanceBan: InstanceBanType? { nil }
    var blocked: Bool? { nil }
    
    var postCount: Int? { nil }
    var postScore: Int? { nil }
    var commentCount: Int? { nil }
    var commentScore: Int? { nil }
    
    var instance: Instance1? { nil }
    var moderatedCommunities: [Community1]? { nil }
    
    var isMlemDeveloper: Bool { developerNames.contains(actorId.absoluteString) }
    
    func getFlairs(
        postContext: (any Post)? = nil,
        communityContext: (any Community)? = nil
    ) -> [PersonFlair] { isMlemDeveloper ? [.developer] : [] }
}
