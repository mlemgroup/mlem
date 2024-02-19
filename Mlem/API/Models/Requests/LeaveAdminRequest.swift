//
//  LeaveAdminRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct LeaveAdminRequest: APIPostRequest {
    typealias Response = APIGetSiteResponse

    let path = "/user/leave_admin"
    let body: Body?

    init() {
        self.body = nil
    }
}
