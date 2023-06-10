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

struct GetPersonDetailsRequest: APIRequest {
    
    typealias Response = GetPersonDetailsResponse
    
    let endpoint: URL
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    
    init(
        accessToken: String,
        instanceURL: URL,
        username: String? = nil,
        personId: Int? = nil
    ) throws {
        guard username != nil || personId != nil else {
            // either `username` OR `personId` must be supplied
            throw GetPersonDetailsRequestError.invalidArguments
        }
        
        var queryItems: [URLQueryItem] = [.init(name: "auth", value: accessToken)]
        
        if let username {
            guard let host = instanceURL.host() else {
                throw GetPersonDetailsRequestError.unableToDetermineInstanceHost
            }
            
            queryItems.append(.init(name: "username", value: "\(username)@\(host)"))
        } else if let personId {
            queryItems.append(.init(name: "person_id", value: "\(personId)"))
        }

        self.queryItems = queryItems
        self.endpoint = instanceURL
            .appending(path: "user")
            .appending(queryItems: queryItems)
        self.method = .get
    }
}

struct GetPersonDetailsResponse: Decodable {
    let comments: [APICommentView]
    let moderates: [APICommunityModeratorView]
    let personView: APIPersonView
    let posts: [APIPostView]
}
