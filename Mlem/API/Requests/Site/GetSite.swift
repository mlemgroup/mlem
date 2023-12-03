//
//  GetSite.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

// lemmy_api_common::site::GetSite
struct GetSiteRequest: APIGetRequest {
    typealias Response = SiteResponse

    let instanceURL: URL
    let path = "site"
    let queryItems: [URLQueryItem]

    init(session: APISession) throws {
        self.instanceURL = try session.instanceUrl
        var queryItems: [URLQueryItem] = []
        
        if let token = try? session.token {
            queryItems.append(
                .init(name: "auth", value: token)
            )
        }
        
        self.queryItems = queryItems
    }

    init(instanceURL: URL) {
        self.instanceURL = instanceURL
        self.queryItems = []
    }
}

// lemmy_api_common::site::SiteResponse
struct SiteResponse: Decodable {
    let siteView: APISiteView
    let admins: [APIPersonView]
    let version: String
    let myUser: APIMyUserInfo?
    let federatedInstances: APIFederatedInstances?
    let allLanguages: [APILanguage]
    let discussionLanguages: [Int]
    let tagLines: [APITagline]?
}
