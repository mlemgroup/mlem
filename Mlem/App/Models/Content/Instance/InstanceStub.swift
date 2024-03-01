////
////  InstanceStub.swift
////  Mlem
////
////  Created by Sjmarf on 09/02/2024.
////
//
// import Dependencies
// import SwiftUI
//
//// TODO: rename to InstanceConnection? Is this altogether redundant with ApiClient????
// @Observable
// final class InstanceStub: InstanceStubProviding, CacheIdentifiable {
//    typealias ApiType = URL
//    var stub: InstanceStub { self }
//
//    var source: ApiClient { api }
//
//    let url: URL
//    var actorId: URL { url }
//    var api: ApiClient
//
//    // TODO: remove me
//    func setApi(_ newApi: ApiClient) {
//        api = newApi
//    }
//
//    var cacheId: Int {
//        var hasher: Hasher = .init()
//        hasher.combine(actorId)
//        hasher.combine(api)
//        return hasher.finalize()
//    }
//
////    static func createModel(url: URL) -> InstanceStub {
////        if let existing = cachedItems.first(where: { $0.content?.url == url })?.content! {
////            return existing
////        }
////        let newItem = InstanceStub(url: url)
////        cachedItems.append(.init(content: newItem))
////        return newItem
////    }
//
//    // init
//
//    private init(url: URL) {
//        self.url = url
//        self.api = .init(baseUrl: url)
//    }
//
//    static func == (lhs: InstanceStub, rhs: InstanceStub) -> Bool {
//        lhs.url == rhs.url
//    }
//
//    func upgrade() async throws -> Instance3 {
//        let response = try await api.getSite()
//        return .init(source: api, from: response)
//    }
// }
//
// extension InstanceStub: Mockable {
//    static let mock: InstanceStub = .init(url: URL(string: "https://lemmy.world")!)
// }
