//
//  InstanceStub.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Dependencies
import SwiftUI

protocol InstanceStubProviding: APISource {
    var url: URL { get }
}

@Observable
class NewInstanceStub: InstanceStubProviding, ContentStub {
    static let cache: ContentStubCache<NewInstanceStub> = .init()
    var instance: NewInstanceStub { self }
    let caches: BaseCacheGroup = .init()
    
    let url: URL
    var actorId: URL { url }

    @ObservationIgnored lazy var api: NewAPIClient = {
        return NewAPIClient(baseUrl: url)
    }()
    
    /// Return a cached InstanceStub if available, or create and return a new InstanceStub otherwise.
    static func create(url: URL) -> NewInstanceStub {
        return cache.createModel(for: url.hashValue) ?? .init(url: url)
    }
    
    private init(url: URL) {
        self.url = url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static func == (lhs: NewInstanceStub, rhs: NewInstanceStub) -> Bool {
        lhs.url == rhs.url
    }
    
    func upgrade() async -> InstanceTier1? {
        
    }
}
