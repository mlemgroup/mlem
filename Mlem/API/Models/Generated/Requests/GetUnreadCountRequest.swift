//
//  GetUnreadCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetUnreadCountRequest: APIGetRequest {
    typealias Response = APIGetUnreadCountResponse

    let path = "/user/unread_count"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
