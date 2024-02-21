//
//  LeaveAdminRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LeaveAdminRequest: ApiPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = ApiGetSiteResponse

    let path = "/user/leave_admin"
    let body: Body?

    init() {
        self.body = nil
    }
}
