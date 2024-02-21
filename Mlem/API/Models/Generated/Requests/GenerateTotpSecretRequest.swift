//
//  GenerateTotpSecretRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GenerateTotpSecretRequest: ApiPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = ApiGenerateTotpSecretResponse

    let path = "/user/totp/generate"
    let body: Body?

    init() {
        self.body = nil
    }
}
