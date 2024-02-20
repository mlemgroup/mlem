//
//  GenerateTotpSecretRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GenerateTotpSecretRequest: APIPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = APIGenerateTotpSecretResponse

    let path = "/user/totp/generate"
    let body: Body?

    init() {
        self.body = nil
    }
}
