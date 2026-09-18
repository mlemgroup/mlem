//
//  ContentStub.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-13.
//

import Foundation

public enum ContentStub {
    case post(PostStub)
    case comment(CommentStub)
    case community(CommunityStub)
    case person(PersonStub)
    case instance(InstanceStub)

    public var url: URL? {
        switch self {
        case let .post(post):
            post.url
        case let .comment(comment):
            comment.url
        case let .community(community):
            communityUrl(community)
        case let .person(person):
            personUrl(person)
        case let .instance(instance): instance.url()
        }
    }
}

private func communityUrl(_ stub: CommunityStub) -> URL? {
    switch stub.reference {
    case let .url(url): url
    default: nil
    }
}
    

private func personUrl(_ stub: PersonStub) -> URL? {
    switch stub.reference {
    case let .url(url): url
    default: nil
    }
}
    
