//
//  GetCaptchaRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetCaptchaRequest: ApiGetRequest {
    typealias Response = ApiGetCaptchaResponse

    let path = "/user/get_captcha"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
