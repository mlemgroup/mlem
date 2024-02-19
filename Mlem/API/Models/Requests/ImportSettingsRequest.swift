//
//  ImportSettingsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ImportSettingsRequest: APIPostRequest {
    typealias Response = APISuccessResponse

    let path = "/user/import_settings"
    let body: Body?

    init() {
        self.body = nil
    }
}
