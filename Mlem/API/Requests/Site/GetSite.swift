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

    let path = "site"
    let queryItems: [URLQueryItem]

    init() {
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

extension SiteResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { siteView.site.actorId }
    var id: Int { siteView.site.id }
}
