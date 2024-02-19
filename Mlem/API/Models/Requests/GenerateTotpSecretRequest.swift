//
//  GenerateTotpSecretRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GenerateTotpSecretRequest: APIPostRequest {
    typealias Response = APIGenerateTotpSecretResponse

    let path = "/user/totp/generate"
    let body: Body?

    init() {
        self.body = nil
    }
}
