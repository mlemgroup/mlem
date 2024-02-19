//
//  UpdateTotpRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct UpdateTotpRequest: APIPostRequest {
    typealias Body = APIUpdateTotp
    typealias Response = APIUpdateTotpResponse

    let path = "/user/totp/update"
    let body: Body?

    init(
        totpToken: String,
        enabled: Bool
    ) {
        self.body = .init(
            totp_token: totpToken,
            enabled: enabled
        )
    }
}
