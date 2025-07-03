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
        connection.setMockContext(.init(siteVersion: .v0_19_9, myPersonId: nil))
        self.connection = connection
    }
    
    override func perform<Request: RestRequest>(
        _ request: Request,
        tokenOverride: String? = nil,
        requiresToken: Bool = true
    ) async throws -> Request.Response {
        if let request = request as? ListPostsRequest, let params = request.parameters {
            return ApiGetPostsResponse(
                posts: posts.map(\.apiPostView),
                nextPage: nil,
                prevPage: nil
            ) as! Request.Response
        }
    
        if let request = request as? ListCommentsRequest, let params = request.parameters {
            return ApiGetCommentsResponse(
                comments: comments.map(\.apiCommentView),
                nextPage: nil,
                prevPage: nil
            ) as! Request.Response
        }
    
        if let request = request as? ReadPersonRequest, let params = request.parameters {
            if let person = people.first(where: { $0.id == params.personId })?.apiPersonView {
                return ApiGetPersonDetailsResponse(
                    personView: person,
                    comments: nil,
                    posts: posts.filter { $0.creator.id == params.personId }.map(\.apiPostView),
                    moderates: [],
                    site: nil
                ) as! Request.Response
            }
        }
    
        if let request = request as? ResolveObjectRequest, let params = request.parameters {
            return ApiResolveObjectResponse(
                comment: comments.first(where: { $0.actorId.description == params.q })?.apiCommentView,
                post: posts.first(where: { $0.actorId.description == params.q })?.apiPostView,
                community: communities.first(where: { $0.actorId.description == params.q })?.apiCommunityView,
                person: people.first(where: { $0.actorId.description == params.q })?.apiPersonView
            ) as! Request.Response
        }
    
        if let request = request as? GetCommunityRequest, let params = request.parameters {
            if let community = communities.first(where: { $0.id == params.id })?.apiCommunityView {
                return ApiGetCommunityResponse(
                    communityView: community,
                    site: nil,
                    moderators: [],
                    discussionLanguages: []
                ) as! Request.Response
            }
        }
    
        if let request = request as? SearchRequest, let params = request.parameters {
            return ApiSearchResponse(
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
