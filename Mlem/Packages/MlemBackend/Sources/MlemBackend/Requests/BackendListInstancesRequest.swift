//
//  BackendListInstancesRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Foundation
import Rest

internal struct BackendListInstancesRequest: GetRequest {
    struct Parameters: Encodable {
        let minTotalUsers: Int?
        let minMonthlyUsers: Int?
    }

    typealias Response = [InstanceSummary]
    
    let path: String = "v1/stats/instances"
    var parameters: Parameters?

    init(minTotalUsers: Int?, minMonthlyUsers: Int?) {
        self.parameters = .init(
            minTotalUsers: minTotalUsers,
            minMonthlyUsers: minMonthlyUsers
        )
    }
}
