//
//  ApproveRegistrationApplicationRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ApproveRegistrationApplicationRequest: ApiPutRequest {
    typealias Body = ApiApproveRegistrationApplication
    typealias Response = ApiRegistrationApplicationResponse

    let path = "/admin/registration_application/approve"
    let body: Body?

    init(
        id: Int,
        approve: Bool,
        denyReason: String?
    ) {
        self.body = .init(
            id: id,
            approve: approve,
            denyReason: denyReason
        )
    }
}
