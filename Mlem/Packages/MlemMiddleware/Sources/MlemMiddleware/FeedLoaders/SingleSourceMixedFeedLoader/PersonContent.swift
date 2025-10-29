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
        case post(Post2)
        case comment(Comment2)
    }
    
    public init(wrappedValue: PersonContent.Value) {
        self.wrappedValue = wrappedValue
    }
    
    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch wrappedValue {
        case let .post(post2): post2.sortVal(sortType: sortType)
        case let .comment(comment2): comment2.sortVal(sortType: sortType)
        }
    }
    
    public var actorId: ActorIdentifier {
        switch wrappedValue {
        case let .post(post2): post2.actorId
        case let .comment(comment2): comment2.actorId
        }
    }
    
    public var api: ApiClient {
        switch wrappedValue {
        case let .post(post2): post2.api
        case let .comment(comment2): comment2.api
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch wrappedValue {
        case let .post(post2):
            hasher.combine(post2)
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
