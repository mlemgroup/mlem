//
//  InstanceStub.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Dependencies
import SwiftUI

@Observable
class NewInstanceStub: InstanceStubProviding, APISource {
    static let cache: ContentStubCache<NewInstanceStub> = .init()
    var stub: InstanceStub { self }
    var instance: NewInstanceStub { self }
    let caches: BaseCacheGroup = .init()
    
    let url: URL
    var actorId: URL { url }

    @ObservationIgnored lazy var api: NewAPIClient = {
        return NewAPIClient(baseUrl: url)
    }()
    
    static var cachedItems: [WeakReference<Content>] = .init()
    
    static func createModel(url: URL) -> NewInstanceStub {
        if let existing = cachedItems.first(where: { $0.content.url == url })?.content! {
            return existing
        }
        let newItem = .init(url: url)
        cachedItems.append(.init(content: newItem))
    }
    
    private init(url: URL) {
        self.url = url
    }
    
    static func == (lhs: NewInstanceStub, rhs: NewInstanceStub) -> Bool {
        lhs.url == rhs.url
    }
    
    func upgrade() async throws -> Instance3 {
        let response = try await api.getSite()
        return .create(from: response)
    }
}
