//
//  ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2023.
//

import Foundation

protocol ContentModel: ActorIdentifiable, Identifiable {
    associatedtype ApiType: ActorIdentifiable & Identifiable where ApiType.ID == ID
    
    var source: any ApiSource { get }
    init(source: any ApiSource, from: ApiType)
    func update(with: ApiType)
}

extension ContentModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
        hasher.combine(source.actorId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension ContentModel where Self.ApiType: Mockable {
    static func mock(_ apiItem: ApiType = .mock) -> Self {
        .init(source: MockApiSource(), from: apiItem)
    }
}
