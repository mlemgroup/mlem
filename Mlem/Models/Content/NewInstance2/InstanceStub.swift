//
//  InstanceStub.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Dependencies
import SwiftUI

protocol InstanceStubProviding: APISource {
    var name: String { get }
}

@Observable
class NewInstanceStub: InstanceStubProviding, ContentStub {
    static let cache: ContentStubCache<NewInstanceStub> = .init()
    var instance: NewInstanceStub { self }
    let caches: DependentContentCacheGroup = .init()
    
    let name: String

    @ObservationIgnored lazy var api: NewAPIClient = {
        if let url = URL(string: "https://\(instance.name)") {
            return NewAPIClient(baseUrl: url)
        }
        print("ERROR: Cannot resolve ApiClient url!")
        return .init(baseUrl: URL(string: "https://lemmy.world!")!)
    }()
    
    /// Return a cached InstanceStub if available, or create and return a new InstanceStub otherwise.
    static func create(name: String) -> NewInstanceStub {
        return cache.createModel(for: name.hashValue) ?? .init(name: name)
    }
    
    private init(name: String) {
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: NewInstanceStub, rhs: NewInstanceStub) -> Bool {
        lhs.name == rhs.name
    }
    
    func upgrade() async -> InstanceTier1? {
        
    }
}
