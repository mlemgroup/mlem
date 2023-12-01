//
//  SaveUserSettings.swift
//  Mlem
//
//  Created by Sjmarf on 23/11/2023.
//

import Foundation

struct SaveUserSettingsRequest: APIPutRequest {
    typealias Response = SaveUserSettingsCompatibilityResponse

    let instanceURL: URL
    let path = "user/save_user_settings"
    let body: Body

    // lemmy_api_common::user::SaveUserSettings
    
    // Some properties not added yet https://join-lemmy.org/api/interfaces/SaveUserSettings.html#avatar
    
    struct Body: Encodable {
        let avatar: String?
        let banner: String?
        let bio: String?
        let botAccount: Bool?
        let defaultListingType: APIListingType?
        let defaultSortType: PostSortType?
        let discussionLanguages: [Int]?
        let displayName: String?
        let email: String?
        let generateTotp2fa: Bool?
        let interfaceLanguage: String?
        let matrixUserId: String?
        let openLinksInNewTab: Bool?
        let sendNotificationsToEmail: Bool?
        let showAvatars: Bool?
        let showBotAccounts: Bool?
        let showNewPostNotifs: Bool?
        let showNsfw: Bool?
        let showReadPosts: Bool?
        let showScores: Bool?
        let theme: String?
        
        let auth: String
    }

    init(
        session: APISession,
        body: Body
    ) throws {
        self.instanceURL = try session.instanceUrl

        self.body = body
    }
}
