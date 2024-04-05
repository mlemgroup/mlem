//
//  ApproveRegistrationApplicationRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct ApproveRegistrationApplicationRequest: APIPutRequest {
    typealias Response = APIRegistrationApplicationResponse
    
    let instanceURL: URL
    let path = "admin/registration_application/approve"
    let body: Body
    
    struct Body: Encodable {
        let id: Int
        let approve: Bool
        let deny_reason: String?
        let auth: String
    }
    
    init(
        session: APISession,
        id: Int,
        approve: Bool,
        denyReason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            id: id,
            approve: approve,
            deny_reason: denyReason,
            auth: session.token
        )
    }
}

struct APIRegistrationApplicationResponse: Decodable {
    let registrationApplication: APIRegistrationApplicationView
}
