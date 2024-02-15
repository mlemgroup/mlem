//
//  APISource.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol APISource: AnyObject, ActorIdentifiable, Equatable {
    var caches: BaseCacheGroup { get }
    var api: NewAPIClient { get }
    var instance: NewInstanceStub { get }
}

class MockAPISource: APISource {
    let actorId: URL = .init(string: "https://lemmy.world")!
    let instance: NewInstanceStub = .mock()
    var api: NewAPIClient { fatalError("You cannot access the 'api' property of MockAPISource.") }
}
