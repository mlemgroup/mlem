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

struct PostProperties {
    var id: Int?
    var title: String?
    var votes: VotesModel?
    var linkUrl: URL??
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
            provideValue: { try await self.upgrade() })
    }

    @ObservationIgnored
    public lazy var title: ExpectedValue<String> = expectedValue(\.title)
  
    @ObservationIgnored
    public lazy var linkUrl: ExpectedValue<URL?> = expectedValue(\.linkUrl)
    
    @ObservationIgnored
    public lazy var votes: ExpectedValue<VotesModel> = expectedValue(\.votes)

    public func vote() async throws {
        var myVote: VotesModel
        var id: Int
        if let existingVotes = properties.votes, let existingId = properties.id {
            myVote = existingVotes
            id = existingId
        } else {
            let upgraded = try await upgrade()
            myVote = upgraded.post.votes
            id = upgraded.post.post.id
        }
        
        let response = try await api.repository.voteOnPost(id: id, score: myVote.myVote == .upvote ? .none : .upvote)
        properties.votes = response.votes
    }
   
    @discardableResult
    private func upgrade() async throws -> Post3Snapshot {
        let post2 = try await api.repository.getPost(url: url)
        let ret = try await api.repository.getPost(id: post2.post.id)
        await Task { @MainActor in
            properties.id = ret.post.post.id
            properties.title = ret.post.post.title
            properties.votes = ret.post.votes
            properties.linkUrl = ret.post.post.linkUrl
        }.value
        return ret
    }
}
