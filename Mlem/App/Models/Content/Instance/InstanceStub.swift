//
//  InstanceStub.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Dependencies
import SwiftUI

@Observable
final class InstanceStub: InstanceStubProviding {
    var stub: InstanceStub { self }
    let caches: BaseCacheGroup = .init()
    
    let url: URL
    var actorId: URL { url }
    var api: ApiClient
    
    // TODO: remove me
    func setApi(_ newApi: ApiClient) {
        api = newApi
    }
    
    static var cachedItems: [WeakReference<InstanceStub>] = .init()
    
    static func createModel(url: URL) -> InstanceStub {
        if let existing = cachedItems.first(where: { $0.content?.url == url })?.content! {
            return existing
        }
        let newItem = InstanceStub(url: url)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
    
    private init(url: URL) {
        self.url = url
        self.api = .init(baseUrl: url)
    }
    
    static func == (lhs: InstanceStub, rhs: InstanceStub) -> Bool {
        lhs.url == rhs.url
    }
    
    func upgrade() async throws -> Instance3 {
        let response = try await api.getSite()
        return .init(source: api, from: response)
    }
}

extension InstanceStub: Mockable {
    static let mock: InstanceStub = .init(url: URL(string: "https://lemmy.world")!)
}
