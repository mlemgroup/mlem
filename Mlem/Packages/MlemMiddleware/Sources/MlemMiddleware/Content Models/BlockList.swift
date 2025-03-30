//
//  BlockList.swift
//
//
//  Created by Sjmarf on 08/07/2024.
//

import Foundation

@Observable
public class BlockList {
    private let api: ApiClient

    /// Mapping `actorId` to `id`.
    var people: [ActorIdentifier: Int] = .init()
    /// Mapping `actorId` to `id`.
    var communities: [ActorIdentifier: Int] = .init()
    /// Mapping `actorId` to `instanceId`.
    var instances: [ActorIdentifier: Int] = .init()

    init(
        api: ApiClient,
        people: [ActorIdentifier: Int],
        communities: [ActorIdentifier: Int],
        instances: [ActorIdentifier: Int]
    ) {
        self.api = api
        self.people = people
        self.communities = communities
        self.instances = instances
    }
    
    convenience init(
        api: ApiClient,
        people: [ApiPersonBlockView],
        communities: [ApiCommunityBlockView],
        instances: [ApiInstanceBlockView]
    ) {
        self.init(
            api: api,
            people: [ActorIdentifier: Int](),
            communities: [ActorIdentifier: Int](),
            instances: [ActorIdentifier: Int]()
        )
        
        update(people: people, communities: communities, instances: instances)
    }
    
    convenience init(api: ApiClient, myUserInfo: ApiMyUserInfo) {
        self.init(
            api: api,
            people: myUserInfo.personBlocks,
            communities: myUserInfo.communityBlocks,
            instances: myUserInfo.instanceBlocks ?? []
        )
    }
    
    func update(
        people newPeople: [ApiPersonBlockView],
        communities newCommunities: [ApiCommunityBlockView],
        instances newInstances: [ApiInstanceBlockView]
    ) {
        let newPeople: [ActorIdentifier: Int] = newPeople.reduce(into: [:]) {
            $0[$1.target.actorId] = $1.target.id
        }
        let newCommunities: [ActorIdentifier: Int] = newCommunities.reduce(into: [:]) {
            $0[$1.community.actorId] = $1.community.id
        }
        
        let newInstances: [ActorIdentifier: Int] = newInstances.reduce(into: [:]) {
            let actorId: ActorIdentifier = .instance(host: $1.instance.domain)
            $0[actorId] = $1.instance.id
        }
        
        // People
        
        let oldPeopleKeys = Set(people.keys)
        let newPeopleKeys = Set(newPeople.keys)

        for key in newPeopleKeys.subtracting(oldPeopleKeys) {
            if let id = newPeople[key], let person = api.caches.person1.retrieveModel(cacheId: id) {
                person.blockedManager.updateWithReceivedValue(true, semaphore: nil)
            }
        }
        for key in oldPeopleKeys.subtracting(newPeopleKeys) {
            if let id = people[key], let person = api.caches.person1.retrieveModel(cacheId: id) {
                person.blockedManager.updateWithReceivedValue(false, semaphore: nil)
            }
        }
        
        // Communities
        
        let oldCommunitiesKeys = Set(people.keys)
        let newCommunitiesKeys = Set(newPeople.keys)

        for key in newCommunitiesKeys.subtracting(oldCommunitiesKeys) {
            if let id = newCommunities[key], let community = api.caches.community1.retrieveModel(cacheId: id) {
                community.blockedManager.updateWithReceivedValue(true, semaphore: nil)
            }
        }
        for key in oldCommunitiesKeys.subtracting(newCommunitiesKeys) {
            if let id = communities[key], let community = api.caches.community1.retrieveModel(cacheId: id) {
                community.blockedManager.updateWithReceivedValue(false, semaphore: nil)
            }
        }
        
        // Instances
        
        let oldInstancesKeys = Set(instances.keys)
        let newInstancesKeys = Set(newInstances.keys)

        for key in newInstancesKeys.subtracting(oldInstancesKeys) {
            if let id = newInstances[key], let instance = api.caches.instance1.retrieveModel(instanceId: id) {
                instance.blockedManager.updateWithReceivedValue(true, semaphore: nil)
            }
        }
        for key in oldInstancesKeys.subtracting(newInstancesKeys) {
            if let id = instances[key], let instance = api.caches.instance1.retrieveModel(instanceId: id) {
                instance.blockedManager.updateWithReceivedValue(false, semaphore: nil)
            }
        }

        people = newPeople
        communities = newCommunities
        instances = newInstances
    }
    
    func update(myUserInfo: ApiMyUserInfo) {
        update(
            people: myUserInfo.personBlocks,
            communities: myUserInfo.communityBlocks,
            instances: myUserInfo.instanceBlocks ?? []
        )
    }
    
    public func contains(personActorId: ActorIdentifier) -> Bool {
        people.keys.contains(personActorId)
    }
    
    public func contains(_ person: any Person) -> Bool {
        people.keys.contains(person.actorId)
    }
    
    public func contains(communityActorId: ActorIdentifier) -> Bool {
        communities.keys.contains(communityActorId)
    }
    
    public func contains(_ community: any Community) -> Bool {
        communities.keys.contains(community.actorId)
    }
    
    public func contains(_ instance: any InstanceStubProviding) -> Bool {
        instances.keys.contains(instance.actorId)
    }
    
    public func idOfBlockedPerson(actorId: ActorIdentifier) -> Int? { people[actorId] }
    public func idOfBlockedCommunity(actorId: ActorIdentifier) -> Int? { communities[actorId] }
    public func instanceIdOfBlockedInstance(actorId: ActorIdentifier) -> Int? { instances[actorId] }
    
    public var personCount: Int { people.count }
    public var communityCount: Int { communities.count }
    public var instanceCount: Int { instances.count }
}
