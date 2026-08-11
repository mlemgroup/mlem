//
//  PersonContent.swift
//
//
//  Created by Eric Andrews on 2024-07-21.
//

import Foundation

public class PersonContent: Hashable, Equatable, FeedLoadable, ActorIdentifiable {
    public typealias FilterType = PersonContentFilterType
    
    public let wrappedValue: Value
    
    public enum Value {
        // This always comes from GetPersonDetailsRequest, so we can know we're getting Post2 and Comment2
        case post(Post)
        case comment(Comment)
    }
    
    public init(wrappedValue: PersonContent.Value) {
        self.wrappedValue = wrappedValue
    }

    public static func post(_ post: Post) -> PersonContent {
        .init(wrappedValue: .post(post))
    }

    public static func comment(_ comment: Comment) -> PersonContent {
        .init(wrappedValue: .comment(comment))
    }
    
    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch wrappedValue {
        case let .post(post): post.sortVal(sortType: sortType)
        case let .comment(comment): comment.sortVal(sortType: sortType)
        }
    }

    public var post: Post? {
        switch wrappedValue {
        case let .post(post): post
        case .comment: nil
        }
    }

    public var comment: Comment? {
        switch wrappedValue {
        case let .comment(comment): comment
        case .post: nil
        }
    }
    
    public var actorId: ActorIdentifier {
        switch wrappedValue {
        case let .post(post): post.actorId
        case let .comment(comment2): comment2.actorId
        }
    }
    
    public var api: ApiClient {
        switch wrappedValue {
        case let .post(post): post.api
        case let .comment(comment2): comment2.api
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch wrappedValue {
        case let .post(post):
            hasher.combine(post)
            hasher.combine(ContentType.post)
        case let .comment(comment2):
            hasher.combine(comment2)
            hasher.combine(ContentType.comment)
        }
    }
    
    public static func == (lhs: PersonContent, rhs: PersonContent) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
