//
//  APIMyUserInfo.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023
//

import Foundation

// lemmy_api_common::site::MyUserInfo
struct APIMyUserInfo: Decodable {
    // Some properties aren't implemented yet: https://join-lemmy.org/api/interfaces/MyUserInfo.html
    var localUserView: APILocalUserView
    var discussionLanguages: [Int]
}

extension APIMyUserInfo: Equatable {
    static func == (lhs: APIMyUserInfo, rhs: APIMyUserInfo) -> Bool {
        lhs.localUserView.person.id == rhs.localUserView.person.id
    }
}
