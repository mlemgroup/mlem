//
//  UnifiedPostModel.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-12-18.
//

import Observation
import Foundation

public class ExpectedValue<T> {
    let getValue: () -> T?
    let provideValue: () async throws -> Void
    
    public var value: T? {
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
    
    init(getValue: @escaping () -> T?, provideValue: @escaping () async throws -> Void) {
        self.getValue = getValue
        self.provideValue = provideValue
    }
}

//public enum ExpectedOptional<T> {
//    case waiting
//    case resolved(T?)
//    
//    /// Useful if you want this to behave like a normal optional that is nil until provided
//    var value: T? {
//        switch self {
//        case let .resolved(value): value
//        default: nil
//        }
//    }
//}

struct PostProperties {
    var title: String?
    var linkUrl: URL??
    // var linkUrl: ExpectedOptional<URL?> = .waiting
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
    
    private func expectedValue<T>(_ keyPath: WritableKeyPath<PostProperties, T?>) -> ExpectedValue<T> {
        .init(
            getValue: { self.properties[keyPath: keyPath] },
            provideValue: upgrade)
    }

    @ObservationIgnored
    public lazy var title: ExpectedValue<String> = expectedValue(\.title)
  
    @ObservationIgnored
    public lazy var linkUrl: ExpectedValue<URL?> = expectedValue(\.linkUrl)
    
//    @ObservationIgnored
//    public lazy var linkUrl: ExpectedValue<ExpectedOptional<URL?>> = .init(
//        getValue: { self.properties.linkUrl },
//        provideValue: upgrade
//    )
    
    private func upgrade() async throws {
        let post2 = try await api.repository.getPost(url: url)
        let ret = try await api.repository.getPost(id: post2.post.id)
        Task { @MainActor in
            properties.title = ret.post.post.title
            properties.linkUrl = ret.post.post.linkUrl
            // properties.linkUrl = .resolved(ret.post.post.linkUrl)
        }
    }
}
