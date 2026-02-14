//
//  PersonCache.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public enum AnyPersonSnapshot: CacheIdentifiable {
    case person1(Person1Snapshot)
    case person2(Person2Snapshot)
    case person3(Person3Snapshot)
    case person4(Person4Snapshot)
    
    static func person1(_ snapshot: Person1Snapshot?) -> AnyPersonSnapshot? {
        if let snapshot {
            return .person1(snapshot)
        }
        return nil
    }
    
    static func person2(_ snapshot: Person2Snapshot?) -> AnyPersonSnapshot? {
        if let snapshot {
            return .person2(snapshot)
        }
        return nil
    }
    
    static func person3(_ snapshot: Person3Snapshot?) -> AnyPersonSnapshot? {
        if let snapshot {
            return .person3(snapshot)
        }
        return nil
    }
    
    static func person4(_ snapshot: Person4Snapshot?) -> AnyPersonSnapshot? {
        if let snapshot {
            return .person4(snapshot)
        }
        return nil
    }
    
    public var cacheId: Int {
        switch self {
        case let .person1(snapshot): snapshot.cacheId
        case let .person2(snapshot): snapshot.cacheId
        case let .person3(snapshot): snapshot.cacheId
        case let .person4(snapshot): snapshot.cacheId
        }
    }
}

class PersonCache: ApiTypeBackedCache<Person, AnyPersonSnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyPersonSnapshot) -> Person {
        return .init(api: api, properties: .init(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Person, with apiType: AnyPersonSnapshot, semaphore: UInt? = nil) {
        // attempt a direct update through the queue to avoid overwriting more recent data, and also
        // synchronously perform softUpdate to ensure high-tier data is available where expected
        let properties: PersonProperties = .init(api: item.api, snapshot: apiType)
        Task {
            await item.updateQueue.attemptDirectUpdate(with: properties)
        }
        item.softUpdate(with: properties)
    }
}
