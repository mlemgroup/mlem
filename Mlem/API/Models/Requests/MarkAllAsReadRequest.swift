//
//  MarkAllAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct MarkAllAsReadRequest: APIPostRequest {
    typealias Response = APIGetRepliesResponse

    let path = "/user/mark_all_as_read"
    let body: Body?

    init() {
        self.body = nil
    }
}
