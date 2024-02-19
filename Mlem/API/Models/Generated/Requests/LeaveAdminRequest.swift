//
//  LeaveAdminRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LeaveAdminRequest: APIPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = APIGetSiteResponse

    let path = "/user/leave_admin"
    let body: Body?

    init() {
        self.body = nil
    }
}
