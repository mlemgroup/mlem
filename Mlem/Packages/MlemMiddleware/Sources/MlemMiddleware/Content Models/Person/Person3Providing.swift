//
//  User3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

//import Foundation
//
//public protocol Person3Providing: Person2Providing {
//    var person3: Person3 { get }
//    
//    var instance: Instance1? { get }
//    var moderatedCommunities: [Community1] { get }
//}
//
//public extension Person3Providing {
//    var person2: Person2 { person3.person2 }
//    
//    /// Is always `nil` pre-0.19.2, and can be `nil` on 0.19.3 and above, but I'm not sure under what circumstances.
//    var instance: Instance1? { person3.instance }
//    var moderatedCommunities: [Community1] { person3.moderatedCommunities }
//    
//    var instance_: Instance1? { person3.instance }
//    var moderatedCommunities_: [Community1]? { person3.moderatedCommunities }
//}
//
//public extension Person3Providing {
//    func upgrade() async throws -> any DeprecatedPerson { self }
//    
//    func moderates(communityId: Int) -> Bool {
//        moderatedCommunities.contains { $0.id == communityId }
//    }
//    
//    func moderates(communityActorId: ActorIdentifier) -> Bool {
//        moderatedCommunities.contains { $0.actorId == communityActorId }
//    }
//    
//    func moderates(community: any Community) -> Bool {
//        moderates(communityActorId: community.actorId)
//    }
//    
//    /// Returns true if this person can perform moderator actions on the target person
//    func canModerate(_ person: any DeprecatedPerson, in community: any Community3Providing) -> Bool {
//        // admins can moderate anybody but a higher-ranking admin
//        if isAdmin {
//            if person.isAdmin_ ?? false {
//                return api.isHigherAdmin(than: person)
//            }
//            return true
//        }
//        
//        // if this person is not a mod, can't moderate
//        guard let myModIndex = community.moderators.firstIndex(where: { $0.id == id }) else {
//            return false
//        }
//        
//        // if target is a mod, check that this person outranks them
//        if let targetModIndex = community.moderators.firstIndex(where: { $0.id == person.id }) {
//            return myModIndex < targetModIndex
//        }
//        
//        // if target not a mod, can moderate
//        return true
//    }
//}
