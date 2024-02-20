//
//  UpdateTotpRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            totpToken: totpToken,
            enabled: enabled
        )
    }
}
