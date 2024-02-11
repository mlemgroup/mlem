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
    func update(with: APIType, cascade: Bool)
}

protocol ContentStub: Hashable { }

protocol CoreModel: NewContentModel, AnyObject {
    associatedtype BaseEquivalent: BaseModel
    static var cache: CoreContentCache<Self> { get }
    init(from: APIType)
}

extension CoreModel {
    static func create(from apiType: APIType) -> Self {
        return cache.createModel(for: apiType)
    }
    
    func fromInstance(_ instance: NewInstanceStub) -> BaseEquivalent? {
        BaseEquivalent.getCache(for: instance).retrieveModel(sourceInstance: instance, actorId: actorId)
    }
}

protocol BaseModel: NewContentModel, AnyObject, Identifiable where APIType: Identifiable, ID == APIType.ID {
    /// The instance from which the ContentModel was fetched
    var sourceInstance: NewInstanceStub { get }
    init(sourceInstance: NewInstanceStub, from: APIType)
    
    static func getCache(for: NewInstanceStub) -> BaseContentCache<Self>
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
