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
        account: SavedAccount
    ) {
        self.instanceURL = account.instanceLink

        self.queryItems = [
            .init(name: "auth", value: account.accessToken)
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
    let site_view: APISiteView
    let admins: [APIPersonView]
    let online: Int
    let version: String
    let myUser: APIMyUserInfo?
    let federatedInstances: APIFederatedInstances?
    let allLanguages: [APILanguage]
    let discussionLanguages: [Int]
    let tagLines: [APITagline]?
}
