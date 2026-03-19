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
    
    public func getInstances() async throws -> [InstanceSummary] {
        try await perform(BackendListInstancesRequest(
            minTotalUsers: 20,
            minMonthlyUsers: 1
        ))
    }

    internal func fetchTestflightUpdate() async throws {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/v0/mlem/testflight")))
        // testflightUpdate = try jsonDecoder.decode(TestflightUpdate.self, from: data).url
    }
    
    internal func fetchFlairs(enabledOnly: Bool = true) async throws {
    //     let request: URLRequest = .init(url: baseUrl
    //         .appendingPathComponent("/v0/mlem/flairs")
    //         .appending(queryItems: [
    //             .init(name: "enabledOnly", value: enabledOnly.description)
    //         ])
    //     )
    //     let (data, _) = try await URLSession.shared.data(for: request)
    //     let response = try jsonDecoder.decode([MlemFlair].self, from: data)
        
    //     flairs = .init(developers: .init(
    //         response
    //             .filter { [.activeDev, .inactiveDev].contains($0.flairType) }
    //             .map(\.apId)
    //     ))
    }
}
