//
//  SuccessResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-01.
//

import Foundation

// lemmy/crates/api_common/src/lib.rs
struct SuccessResponse: Decodable {
    let success: Bool
    
    // TODO: 0.18 deprecation remove all code below this point
    // To handle multiple API specs, I have defined "compatibility responses" that encompass multiple response specs. These initializers then handle converting the compatibility response to a SuccessResponse.
    init(from compatibilityResponse: MarkReadCompatibilityResponse) {
        if let success = compatibilityResponse.success {
            self.success = success
        } else if compatibilityResponse.postView != nil {
            self.success = true
        } else {
            self.success = false
        }
    }
    
    init(from compatibilityResponse: SaveUserSettingsCompatibilityResponse) {
        self.success = compatibilityResponse.success ?? true
    }
}

struct MarkReadCompatibilityResponse: Decodable {
    let success: Bool?
    let postView: APIPostView?
}

struct SaveUserSettingsCompatibilityResponse: Decodable {
    let success: Bool?
}
