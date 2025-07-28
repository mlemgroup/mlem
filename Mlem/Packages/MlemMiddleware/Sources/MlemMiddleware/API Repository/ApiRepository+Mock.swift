//
//  ApiRepository+Mock.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

import Foundation
import Rest

#if DEBUG

    class MockApiRepository: ApiRepository {
        var posts: [Post2]
        var communities: [Community2]
        var people: [Person2]
        var comments: [Comment2]
    
        init(
            url: URL,
            username: String,
            posts: [Post2] = [],
            communities: [Community2] = [],
            people: [Person2] = [],
            comments: [Comment2] = []
        ) {
            self.posts = posts
            self.communities = communities
            self.people = people
            self.comments = comments
        
            super.init(
                baseUrl: url,
                username: username
            )
            self.token = "" // Not nil so that the views are interactable
            let connection = LemmyConnection(baseUrl: url, token: "")
            connection.setMockContext(.init(siteVersion: .init("0.19.0"), myPersonId: nil))
            self.connection = connection
        }
    
        override func perform<Request: RestRequest>(
            _ request: Request,
            tokenOverride: String? = nil,
            requiresToken: Bool = true
        ) async throws -> Request.Response {
            if let request = request as? LemmyListPostsRequest, request.parameters != nil {
                return LemmyGetPostsResponse(
                    posts: posts.map(\.apiPostView),
                    nextPage: nil,
                    prevPage: nil
                ) as! Request.Response
            }
    
            if let request = request as? LemmyListCommentsRequest, request.parameters != nil {
                return LemmyGetCommentsResponse(
                    comments: comments.map(\.apiCommentView),
                    nextPage: nil,
                    prevPage: nil
                ) as! Request.Response
            }
    
            if let request = request as? LemmyReadPersonRequest, let params = request.parameters {
                if let person = people.first(where: { $0.id == params.personId })?.apiPersonView {
                    return LemmyGetPersonDetailsResponse(
                        personView: person,
                        comments: nil,
                        posts: posts.filter { $0.creator.id == params.personId }.map(\.apiPostView),
                        moderates: [],
                        site: nil
                    ) as! Request.Response
                }
            }
    
            if let request = request as? LemmyResolveObjectRequest, let params = request.parameters {
                return LemmyResolveObjectResponse(
                    comment: comments.first(where: { $0.actorId.description == params.q })?.apiCommentView,
                    post: posts.first(where: { $0.actorId.description == params.q })?.apiPostView,
                    community: communities.first(where: { $0.actorId.description == params.q })?.apiCommunityView,
                    person: people.first(where: { $0.actorId.description == params.q })?.apiPersonView
                ) as! Request.Response
            }
    
            if let request = request as? LemmyGetCommunityRequest, let params = request.parameters {
                if let community = communities.first(where: { $0.id == params.id })?.apiCommunityView {
                    return LemmyGetCommunityResponse(
                        communityView: community,
                        site: nil,
                        moderators: [],
                        discussionLanguages: []
                    ) as! Request.Response
                }
            }
    
            if let request = request as? LemmySearchRequest, let params = request.parameters {
                return LemmySearchResponse(
                    type_: params.type_,
                    comments: [],
                    posts: [],
                    communities: params.type_ == .communities ? communities.map(\.apiCommunityView) : [],
                    users: params.type_ == .users ? people.map(\.apiPersonView) : [],
                    results: nil,
                    nextPage: nil,
                    prevPage: nil
                ) as! Request.Response
            }
    
            throw ApiClientError.insufficientPermissions
        }
    }

#endif
