//
//  CoreModel.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol CoreModel: AnyObject, ActorIdentifiable {
    associatedtype ApiType: ActorIdentifiable
    static var cache: CoreContentCache<Self> { get }
    init(from: ApiType)
    func update(with: ApiType)
}

extension CoreModel {
    static func create(from apiType: ApiType) -> Self {
        cache.createModel(for: apiType)
    }
}
