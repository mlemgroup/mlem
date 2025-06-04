//
//  ApiClient+Mock.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation

#if DEBUG
    public extension ApiClient {
        static let mock: MockApiClient = .init()
    }

    public class MockApiClient: ApiClient {
        public var posts: [Post2]
        public var communities: [Community2]
        public var people: [Person2]
        public var comments: [Comment2]
    
        public init(
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
                url: URL(string: "https://lemmy.world/")!,
                username: ""
            )
            contextDataManager.fetchedValue = .init(siteVersion: .v0_19_9, myPersonId: nil)
            self.token = "" // Not nil so that the views are interactable
        }
    
        override func perform<Request: ApiRequest>(
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
