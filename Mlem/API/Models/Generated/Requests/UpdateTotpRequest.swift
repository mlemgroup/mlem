//
//  UpdateTotpRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct UpdateTotpRequest: ApiPostRequest {
    typealias Body = ApiUpdateTotp
    typealias Response = ApiUpdateTotpResponse

    let path = "/user/totp/update"
    let body: Body?

    init(
        totpToken: String,
        enabled: Bool
    ) {
        self.body = .init(
            totpToken: totpToken,
            enabled: enabled
        )
    }
}
