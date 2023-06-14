//
//  GetPersonDetailsRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

enum GetPersonDetailsRequestError: Error {
    case invalidArguments
    case unableToDetermineInstanceHost
}

struct GetPersonDetailsRequest: APIGetRequest {

    typealias Response = GetPersonDetailsResponse

    let instanceURL: URL
    let path = "user"
    let queryItems: [URLQueryItem]

    // lemmy_api_common::person::GetPersonDetails
    init(
        accessToken: String,
        instanceURL: URL,
        sort: SortingOptions? = nil,
        page: Int? = nil,
        limit: Int? = nil,
        communityId: Int? = nil,
        savedOnly: Bool = false,
        username: String? = nil,
        personId: Int? = nil
    ) throws {
        guard username != nil || personId != nil else {
            // either `username` OR `personId` must be supplied
            throw GetPersonDetailsRequestError.invalidArguments
        }

        self.instanceURL = instanceURL
        var queryItems: [URLQueryItem] = [
            .init(name: "auth", value: accessToken),
            .init(name: "sort", value: sort?.rawValue),
            .init(name: "page", value: page?.description),
            .init(name: "limit", value: limit?.description),
            .init(name: "community_id", value: communityId?.description),
            .init(name: "saved_only", value: String(savedOnly))
        ]

        if var username {
            if !username.contains("@") {
                guard let host = instanceURL.host() else {
                    throw GetPersonDetailsRequestError.unableToDetermineInstanceHost
                }
                username = "\(username)@\(host)"
            }

            queryItems.append(.init(name: "username", value: username))
        } else if let personId {
            queryItems.append(.init(name: "person_id", value: "\(personId)"))
        }

        self.queryItems = queryItems
    }
}

// lemmy_api_common::person::GetPersonDetailsResponse
struct GetPersonDetailsResponse: Decodable {
    let personView: APIPersonView
    let comments: [APICommentView]
    let posts: [APIPostView]
    let moderates: [APICommunityModeratorView]
}
