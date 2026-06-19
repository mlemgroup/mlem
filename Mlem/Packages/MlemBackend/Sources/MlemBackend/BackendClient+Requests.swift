//
//  BackendClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Foundation
import os
import Rest
import SwiftUI
import MlemLogger

extension BackendClient {
    public func healthCheck() async throws -> BackendHealthCheck {
        try await perform(BackendHealthCheckRequest())
    }
    
    public func getInstances(minTotalUsers: Int? = nil, minMonthlyUsers: Int? = nil) async throws -> [InstanceSummary] {
        try await perform(BackendListInstancesRequest(
            minTotalUsers: minTotalUsers,
            minMonthlyUsers: minMonthlyUsers
        ))
    }

    internal func fetchTestflightUpdate() async throws {
        let response = try await perform(BackendGetTestflightUpdateRequest())
        self.testflightUpdate = response.url
    }
    
    internal func fetchFlairs(enabledOnly: Bool = true) async throws {
        let response = try await perform(BackendListFlairsRequest(enabledOnly: enabledOnly))
        
        self.flairs = .init(developers: .init(
            response
                .filter { [.activeDev, .inactiveDev].contains($0.flairType) }
                .map(\.apId)
        ))
    }
}
