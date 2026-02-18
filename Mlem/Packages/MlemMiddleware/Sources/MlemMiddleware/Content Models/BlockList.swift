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
    
    convenience init(api: ApiClient, blocks: BlockListSnapshot) {
        self.init(
            api: api,
            people: blocks.people,
            communities: blocks.communities,
            instances: blocks.instances
        )
    }
    
    func update(blocks: BlockListSnapshot) {
        // People
        
        let oldPeopleKeys = Set(people.keys)
        let newPeopleKeys = Set(blocks.people.keys)

        // bypasses queuing for blocked status
        for key in newPeopleKeys.subtracting(oldPeopleKeys) {
            if let id = blocks.people[key], let person = api.caches.person.retrieveModel(cacheId: id) {
                person.blocked = true
            }
        }
        for key in oldPeopleKeys.subtracting(newPeopleKeys) {
            if let id = people[key], let person = api.caches.person.retrieveModel(cacheId: id) {
                person.blocked = false
            }
        }
        
        // Communities
        
        let oldCommunitiesKeys = Set(communities.keys)
        let newCommunitiesKeys = Set(blocks.communities.keys)

        // bypasses queuing for blocked status
        for key in newCommunitiesKeys.subtracting(oldCommunitiesKeys) {
            if let id = blocks.communities[key], let community = api.caches.community.retrieveModel(cacheId: id) {
                community.blocked = true
            }
        }
        for key in oldCommunitiesKeys.subtracting(newCommunitiesKeys) {
            if let id = communities[key], let community = api.caches.community.retrieveModel(cacheId: id) {
                community.blocked = false
            }
        }
        
        // Instances
        
        let oldInstancesKeys = Set(instances.keys)
        let newInstancesKeys = Set(blocks.instances.keys)

        for key in newInstancesKeys.subtracting(oldInstancesKeys) {
            if let id = blocks.instances[key], let instance = api.caches.instance1.retrieveModel(instanceId: id) {
                instance.blockedManager.updateWithReceivedValue(true, semaphore: nil)
            }
        }
        for key in oldInstancesKeys.subtracting(newInstancesKeys) {
            if let id = instances[key], let instance = api.caches.instance1.retrieveModel(instanceId: id) {
                instance.blockedManager.updateWithReceivedValue(false, semaphore: nil)
            }
        }

        people = blocks.people
        communities = blocks.communities
        instances = blocks.instances
    }
    
    public func contains(personActorId: ActorIdentifier) -> Bool {
        people.keys.contains(personActorId)
    }
    
    public func contains(_ person: Person) -> Bool {
        people.keys.contains(person.actorId)
    }
    
    public func contains(communityActorId: ActorIdentifier) -> Bool {
        communities.keys.contains(communityActorId)
    }
    
    public func contains(_ community: Community) -> Bool {
        communities.keys.contains(community.actorId)
    }
    
    public func contains(instanceActorId: ActorIdentifier) -> Bool {
        instances.keys.contains(instanceActorId)
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
