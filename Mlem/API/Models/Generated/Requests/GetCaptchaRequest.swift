//
//  GetCaptchaRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetCaptchaRequest: APIGetRequest {
    typealias Response = APIGetCaptchaResponse

    let path = "/user/get_captcha"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
