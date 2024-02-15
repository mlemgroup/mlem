//
//  CoreModel.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

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
