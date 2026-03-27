//
//  BackendListFlairsRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Foundation
import Rest

internal struct BackendListFlairsRequest: GetRequest {
    struct Parameters: Encodable {
        let enabledOnly: Bool
    }

    typealias Response = [MlemFlair]
    
    let path: String = "v0/mlem/flairs"
    var parameters: Parameters?

    init(enabledOnly: Bool) {
        self.parameters = .init(enabledOnly: enabledOnly)
    }
}
