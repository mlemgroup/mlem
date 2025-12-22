//
//  UnifiedPostModel.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-12-18.
//

import Observation
import Foundation

public class ExpectedValue<Value> {
    let getValue: () -> Value?
    let provideValue: () async throws -> Void
    
    public var value: Value? {
        get {
            if let ret = getValue() { return ret }
            Task {
                do {
                    try await provideValue()
                } catch {
                    print(error)
                }
            }
            return nil
        }
    }
    
    init(getValue: @escaping () -> Value?, provideValue: @escaping () async throws -> Void) {
        self.getValue = getValue
        self.provideValue = provideValue
    }
}

struct PostProperties {
    var title: String?
}

@Observable
public class UnifiedPostModel {
    public var api: ApiClient
    public var url: URL
    
    public init(api: ApiClient, url: URL) {
        self.api = api
        self.url = url
    }
    
    private var properties: PostProperties = .init()

    @ObservationIgnored
    public lazy var title: ExpectedValue<String> = {
            .init(
                getValue: { self.properties.title },
                provideValue: upgrade)
        }()
    
//    public var title: String? {
//        get {
//            if let ret = properties.title {
//                return ret
//            }
//            Task {
//                do {
//                    try await upgrade()
//                } catch {
//                    print(error)
//                }
//            }
//            return nil
//        }
//    }
    
    private func upgrade() async throws {
        let post2 = try await api.repository.getPost(url: url)
        let ret = try await api.repository.getPost(id: post2.post.id)
        Task { @MainActor in
            properties.title = ret.post.post.title
        }
    }
}
