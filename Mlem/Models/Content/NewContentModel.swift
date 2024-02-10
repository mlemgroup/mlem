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
    func update(with: APIType)
}

protocol ContentStub: Hashable { }

protocol CoreModel: NewContentModel, AnyObject {
    static var cache: CoreContentCache<Self> { get }
    init(from: APIType)
}

extension CoreModel {
    static func create(from apiType: APIType) -> Self {
        return cache.createModel(for: apiType)
    }
}

protocol BaseModel: NewContentModel, Identifiable where APIType: Identifiable, ID == APIType.ID {
    /// The instance from which the ContentModel was fetched
    var sourceInstance: NewInstanceStub { get }
    init(sourceInstance: NewInstanceStub, from: APIType)
}

enum SourceRetargetError: Error {
    case unMatchingInstance
}

protocol InstanceContentModel: NewContentModel {
    init(from: APIType)
}

protocol APISource {
    associatedtype Client: NewAPIClient
    var caches: BaseCacheGroup { get }
    var api: Client { get }
    var instance: NewInstanceStub { get }
}

protocol AuthenticatedAPISource: APISource where Client: AuthenticatedAPIClient { }
