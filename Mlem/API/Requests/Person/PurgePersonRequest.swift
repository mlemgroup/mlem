//
//  PurgePersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct PurgePersonRequest: APIPostRequest {
    typealias Response = SuccessResponse
    
    var instanceURL: URL
    let path = "admin/purge/person"
    let body: Body
    
    struct Body: Codable {
        let person_id: Int
        let reason: String?
    }

    init(
        session: APISession,
        personId: Int,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = .init(
            person_id: personId,
            reason: reason
        )
    }
}
