//
//  InstanceSummary.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemBackend
import MlemMiddleware

public extension InstanceSummary {
    var instanceStub: InstanceStub {
        .init(api: AppState.main.firstApi, actorId: .instance(host: host))
    }
}
