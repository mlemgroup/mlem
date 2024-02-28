//
//  SiteResponse+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension SiteResponse {
    static func mock(
        siteView: APISiteView = .mock(),
        admins: [APIPersonView] = [.mock()],
        version: String = "0.19.0",
        myUser: APIMyUserInfo? = nil,
        federatedInstances: APIFederatedInstances? = nil,
        allLanguages: [APILanguage] = [],
        discussionLanguages: [Int] = [0],
        tagLines: [APITagline]? = nil
    ) -> SiteResponse {
        .init(
            siteView: siteView,
            admins: admins,
            version: version,
            myUser: myUser,
            federatedInstances: federatedInstances,
            allLanguages: allLanguages,
            discussionLanguages: discussionLanguages,
            tagLines: tagLines
        )
    }
}
