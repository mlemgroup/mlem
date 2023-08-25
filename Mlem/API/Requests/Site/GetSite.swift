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

    init(
        session: APISession
    ) {
        self.instanceURL = session.URL
        self.queryItems = [
            .init(name: "auth", value: session.token)
        ]
    }

    init(
        instanceURL: URL
    ) {
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
