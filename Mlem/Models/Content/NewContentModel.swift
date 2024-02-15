//
//  NewContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

protocol ActorIdentifiable: Hashable, Equatable {
    /// The URL of the entity on it's host instance. For example, "https://lemmy.ml/c/mlemapp". Useful for identifying entities across instances.
    var actorId: URL { get }
}

extension ActorIdentifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
}

protocol NewContentModel: ActorIdentifiable, Identifiable {
    associatedtype APIType: ActorIdentifiable & Identifiable where APIType.ID == ID
    
    var source: any APISource { get }
    init(source: any APISource, from: APIType)
    func update(with: APIType)
    
}

protocol CoreModel: AnyObject, ActorIdentifiable {
    associatedtype APIType: ActorIdentifiable
    static var cache: CoreContentCache<Self> { get }
    init(from: APIType)
    func update(with: APIType)
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

protocol APISource: AnyObject, ActorIdentifiable, Equatable {
    associatedtype Client: NewAPIClient
    var caches: BaseCacheGroup { get }
    var api: Client { get }
    var instance: NewInstanceStub { get }
}
