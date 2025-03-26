//
//  ApiPerson+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPerson: ActorIdentifiable, CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }
}
