//
//  MarkAllAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct MarkAllAsReadRequest: APIPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = APIGetRepliesResponse

    let path = "/user/mark_all_as_read"
    let body: Body?

    init() {
        self.body = nil
    }
}
