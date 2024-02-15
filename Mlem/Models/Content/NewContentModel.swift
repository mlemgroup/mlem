//
//  NewContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

protocol NewContentModel: ActorIdentifiable, Identifiable {
    associatedtype APIType: ActorIdentifiable & Identifiable where APIType.ID == ID
    
    var source: any APISource { get }
    init(source: any APISource, from: APIType)
    func update(with: APIType)
}

extension NewContentModel where Self.APIType: Mockable {
    /// Returns a version of the
    static func mock(_ apiItem: APIType = .mock) -> Self {
        return .init(source: MockAPISource(), from: apiItem)
    }
}
