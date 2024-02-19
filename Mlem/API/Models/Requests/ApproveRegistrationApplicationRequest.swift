//
//  ApproveRegistrationApplicationRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ApproveRegistrationApplicationRequest: APIPutRequest {
    typealias Body = APIApproveRegistrationApplication
    typealias Response = APIRegistrationApplicationResponse

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
            deny_reason: denyReason
        )
    }
}
