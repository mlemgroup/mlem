//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Dependencies
import SwiftUI

protocol CommunityStubProviding {
    var source: any APISource { get }
    var id: Int { get }
}

struct CommunityStub: CommunityStubProviding, Hashable {
    var source: any APISource
    let id: Int
    
    init(source: any APISource, id: Int) {
        self.source = source
        self.id = id
    }
    
    static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CommunityStubProviding {
    func upgrade() async throws -> CommunityTier3 {
        let response = try await source.api.getCommunity(id: id)
        return source.caches.community3.createModel(source: source, for: response)
    }
}
