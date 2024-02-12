//
//  NewContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

protocol ActorIdentifiable: Hashable, Equatable {
    var actorId: URL { get }
}

extension ActorIdentifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.actorId == rhs.actorId
    }
}

protocol NewContentModel: ActorIdentifiable {
    associatedtype APIType: ActorIdentifiable
    
    var source: any APISource { get }
    init(source: any APISource, from: APIType)
    func update(with: APIType)
    
}

protocol CoreModel: AnyObject {
    static var cache: CoreContentCache<Self> { get }
    init(from: APIType)
}

extension CoreModel {
    static func create(from apiType: APIType) -> Self {
        return cache.createModel(for: apiType)
    }
}

enum SourceRetargetError: Error {
    case unMatchingInstance
}

protocol InstanceContentModel: NewContentModel {
    init(from: APIType)
}

protocol APISource: ActorIdentifiable {
    associatedtype Client: NewAPIClient
    var caches: BaseCacheGroup { get }
    var api: Client { get }
    var instance: NewInstanceStub { get }
}
