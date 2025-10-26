//
//  BackendClient.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-05-31.
//

import Foundation
import SwiftUI
import os

public enum BackendEnvironment {
    case qc, prod
    
    internal var address: URL {
        switch self {
        case .prod: .init(string: "https://backend.mlemapp.org:8443/")!
        case .qc: .init(string: "https://backend.mlemapp.org:2096/")!
        }
    }
}

@Observable
public class BackendClient {
    internal let log: Logger = .mlemLogger()
    
    public private(set) var environment: BackendEnvironment = .prod
    private let jsonDecoder: JSONDecoder = {
        let decoder: JSONDecoder = .init()
        decoder.dateDecodingStrategy = .custom { decoder in
            let formatter: ISO8601DateFormatter = .init()
            formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
            let dateStr = try decoder.singleValueContainer().decode(String.self)
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid date"))
        }
        return decoder
    }()
    
    public private(set) var flairs: MlemFlairs = .init(developers: .init())
    public private(set) var testflightUpdate: URL?
    
    public static var main: BackendClient = .init()
    private var baseUrl: URL { environment.address }
    
    private init() {
        refresh()
    }
    
    public func healthCheck() async throws -> BackendHealthCheck {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/v0/health")))
        return try jsonDecoder.decode(BackendHealthCheck.self, from: data)
    }
    
    public func getInstances() async throws -> [InstanceSummary] {
        let request: URLRequest = .init(url: baseUrl
            .appendingPathComponent("/v1/stats/instances")
            .appending(queryItems: [
                .init(name: "minTotalUsers", value: "20"),
                .init(name: "minMonthyUsers", value: "1"),
            ])
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        return try jsonDecoder.decode([InstanceSummary].self, from: data)
    }
    
    public func changeEnvironment(to environment: BackendEnvironment) {
        self.environment = environment
        refresh()
    }
    
    private func refresh() {
        Task {
            do {
                try await fetchFlairs()
                try await fetchTestflightUpdate()
            } catch {
                log.error("\(error.localizedDescription)")
            }
        }
    }
    
    private func fetchTestflightUpdate() async throws {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/v0/mlem/testflight")))
        testflightUpdate = try jsonDecoder.decode(TestflightUpdate.self, from: data).url
    }
    
    private func fetchFlairs(enabledOnly: Bool = true) async throws {
        let request: URLRequest = .init(url: baseUrl
            .appendingPathComponent("/v0/mlem/flairs")
            .appending(queryItems: [
                .init(name: "enabledOnly", value: enabledOnly.description)
            ])
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try jsonDecoder.decode([MlemFlair].self, from: data)
        
        flairs = .init(developers: .init(
            response
                .filter { [.activeDev, .inactiveDev].contains($0.flairType) }
                .map(\.apId)
        ))
    }
}
