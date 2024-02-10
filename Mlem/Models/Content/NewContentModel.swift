//
//  NewContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

protocol NewContentModel {
    associatedtype APIType: Identifiable
    var id: APIType.ID { get }
    func update(with: APIType)
}

protocol ContentStub: Hashable { }

protocol IndependentContentModel: NewContentModel, AnyObject {
    static var cache: IndepenentContentCache<Self> { get }
    init(from: APIType)
}

extension IndependentContentModel {
    static func create(from apiType: APIType) -> Self {
        return cache.createModel(for: apiType)
    }
}

protocol DependentContentModel: NewContentModel {
    /// The instance from which the ContentModel was fetched
    var source: any APISource { get set }
    init(source: any APISource, from: APIType)
}

enum SourceRetargetError: Error {
    case unMatchingInstance
}

protocol InstanceContentModel: NewContentModel {
    init(from: APIType)
}

protocol APISource {
    associatedtype Client: NewAPIClient
    var caches: DependentContentCacheGroup { get }
    var api: Client { get }
    var instance: NewInstanceStub { get }
}

protocol AuthenticatedAPISource: APISource where Client: AuthenticatedAPIClient { }
