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
    // From User1Providing.
    var id_: Int? { get }
    var creationDate_: Date? { get }
    var updatedDate_: Date? { get }
    var displayName_: String? { get }
    var description_: String? { get }
    var matrixId_: String? { get }
    var avatar_: URL? { get }
    var banner_: URL? { get }
    var deleted_: Bool? { get }
    var isBot_: Bool? { get }
    var instanceBan_: InstanceBanType? { get }
    var blocked_: Bool? { get }
    
    // From User2Providing.
    var postCount_: Int? { get }
    var postScore_: Int? { get }
    var commentCount_: Int? { get }
    var commentScore_: Int? { get }
    
    // From User3Providing.
    var instance_: Instance1? { get }
    var moderatedCommunities_: [Community1]? { get }
    
    func getFlairs(postContext: (any Post)?, communityContext: (any Community)?) -> [PersonFlair]
}

extension PersonStubProviding {
    static var identifierPrefix: String { "@" }
    
    var id_: Int? { nil }
    var creationDate_: Date? { nil }
    var updatedDate_: Date? { nil }
    var displayName_: String? { nil }
    var description_: String? { nil }
    var matrixId_: String? { nil }
    var avatar_: URL? { nil }
    var banner_: URL? { nil }
    var deleted_: Bool? { nil }
    var isBot_: Bool? { nil }
    var instanceBan_: InstanceBanType? { nil }
    var blocked_: Bool? { nil }
    
    var postCount_: Int? { nil }
    var postScore_: Int? { nil }
    var commentCount_: Int? { nil }
    var commentScore_: Int? { nil }
    
    var instance_: Instance1? { nil }
    var moderatedCommunities_: [Community1]? { nil }
    
    var isMlemDeveloper: Bool { developerNames.contains(actorId.absoluteString) }
    
    func getFlairs(
        postContext: (any Post)? = nil,
        communityContext: (any Community)? = nil
    ) -> [PersonFlair] { isMlemDeveloper ? [.developer] : [] }
}
