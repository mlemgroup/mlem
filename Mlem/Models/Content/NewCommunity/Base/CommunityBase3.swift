//
//  Community3.swift
//  Mlem
//
//  Created by Sjmarf on 11/02/2024.
//

import Foundation

protocol CommunityBase3Providing: CommunityBase2Providing, CommunityCore3Providing { }

@Observable
final class CommunityBase3: CommunityBase3Providing, BaseModel {
    typealias APIType = GetCommunityResponse
    
    // Conformance
    var sourceInstance: NewInstanceStub
    
    // Wrapped layers
    private let core3: CommunityCore3
    private let base2: CommunityBase2
    
    var cachedModerators: [UserBase1] = .init()
    
    // Forwarded properties from Community1
    var id: Int { base2.id }
    
    // Forwarded properties from CommunityCore1
    var actorId: URL { core3.actorId }
    var name: String { core3.name }
    var creationDate: Date { core3.creationDate }
    var updatedDate: Date? { core3.updatedDate }
    var displayName: String { core3.displayName }
    var description: String? { core3.description }
    var removed: Bool { core3.removed }
    var deleted: Bool { core3.deleted }
    var nsfw: Bool { core3.nsfw }
    var avatar: URL? { core3.avatar }
    var banner: URL? { core3.banner }
    var hidden: Bool { core3.hidden }
    var onlyModeratorsCanPost: Bool { core3.onlyModeratorsCanPost }
    
    // Forwarded properties from CommunityCore2
    var subscriberCount: Int { core3.subscriberCount }
    var postCount: Int { core3.postCount }
    var commentCount: Int { core3.commentCount }
    var activeUserCount: ActiveUserCount { core3.activeUserCount }
    
    // Forwarded properties from CommunityCore3
    var instance: InstanceCore1? { core3.instance }
    var discussionLanguages: [Int] { core3.discussionLanguages }
    var defaultPostLanguage: Int? { core3.defaultPostLanguage }
    
    var moderators: [any UserCore1Providing] {
        if cachedModerators.hashValue == core3.coreModerators.hashValue {
            return cachedModerators
        }
        
        // Cached communities are outdated, so we need to merge with the core model to provide the best representation possible
        var users: [any UserCore1Providing] = .init()
        for coreUser in core3.coreModerators {
            if let baseUser = cachedModerators.first(where: { coreUser.actorId == $0.actorId }) {
                users.append(baseUser)
            } else {
                users.append(coreUser)
            }
        }
        return users
    }
    
    required init(sourceInstance: NewInstanceStub, from response: GetCommunityResponse) {
        self.sourceInstance = sourceInstance
        self.core3 = CommunityCore3(from: response)
        self.base2 = sourceInstance.caches.community2.createModel(
            sourceInstance: sourceInstance,
            for: response.communityView
        )
    }
    
    func update(with response: GetCommunityResponse, cascade: Bool = true) {
        if cascade {
            self.core3.update(with: response)
            self.base2.update(with: response.communityView)
        }
    }

    static func getCache(for sourceInstance: NewInstanceStub) -> BaseContentCache<CommunityBase3> {
        return sourceInstance.caches.community3
    }
}
