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
    init(from compatibilityResponse: MarkReadCompatibilityResponse) {
        if let success = compatibilityResponse.success {
            self.success = success
        } else if let postView = compatibilityResponse.postView {
            self.success = true
        } else {
            self.success = false
        }
    }
}

struct MarkReadCompatibilityResponse: Decodable {
    let success: Bool?
    let postView: APIPostView?
}
