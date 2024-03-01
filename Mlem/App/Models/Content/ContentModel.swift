//
//  NewContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

protocol ContentModel: AnyObject, ActorIdentifiable, CacheIdentifiable, Identifiable {
    associatedtype ApiType: CacheIdentifiable & ActorIdentifiable & Identifiable where ApiType.ID == ID
    
    var source: ApiClient { get }
    init(source: ApiClient, from: ApiType)
    func update(with: ApiType)
}

// extension ContentModel where Self.ApiType: Mockable {
//    /// Returns a version of the
//    static func mock(_ apiItem: ApiType = .mock) -> Self {
//        .init(source: MockApiSource(), from: apiItem)
//    }
// }
