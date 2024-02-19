//
//  GetUnreadCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetUnreadCountRequest: APIGetRequest {
    typealias Response = APIGetUnreadCountResponse

    let path = "/user/unread_count"
    let queryItems: [URLQueryItem]

    init() {
        var request: REQUEST_TYPE = BODY_INIT
        self.queryItems = .init()
    }
}
