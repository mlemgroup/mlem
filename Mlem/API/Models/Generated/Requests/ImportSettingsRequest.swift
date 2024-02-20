//
//  ImportSettingsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ImportSettingsRequest: APIPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = APISuccessResponse

    let path = "/user/import_settings"
    let body: Body?

    init() {
        self.body = nil
    }
}
