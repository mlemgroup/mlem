//
//  BackendGetTestflightUpdateRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Rest

internal struct BackendGetTestflightUpdateRequest: GetRequest {
    typealias Parameters = Never
    typealias Response = TestflightUpdate
    
    let path: String = "v0/mlem/testflight"
    let parameters: Parameters? = nil
}
