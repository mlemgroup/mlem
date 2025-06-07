//
//  BackendClient.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-05-31.
//

import Foundation
import SwiftUICore

private let backendAddress: String = "https://backend.mlemapp.org:8443/v0"

@Observable
public class BackendClient {
    private let baseUrl: URL
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

    private init() {
        guard let url = URL(string: backendAddress) else {
            fatalError("Could not form backend URL")
        }
        baseUrl = url
        
        Task {
            do {
                try await fetchFlairs()
                try await fetchTestflightUpdate()
            } catch {
                print(error)
            }
        }
    }
    
    public func healthCheck() async throws -> Bool {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/health")))
        return try jsonDecoder.decode(Bool.self, from: data)
    }
    
    public func getInstances() async throws -> [InstanceSummary] {
        let request: URLRequest = .init(url: baseUrl
            .appendingPathComponent("/stats/instances")
            .appending(queryItems: [
                .init(name: "minUsers", value: "20"),
                .init(name: "minScore", value: "0"),
                .init(name: "allowSus", value: "false")
            ])
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        return try jsonDecoder.decode([InstanceSummary].self, from: data)
    }
    
    private func fetchTestflightUpdate() async throws {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/mlem/testflight")))
        testflightUpdate = try jsonDecoder.decode(TestflightUpdate.self, from: data).url
    }
    
    private func fetchFlairs(enabledOnly: Bool = true) async throws {
        let request: URLRequest = .init(url: baseUrl
            .appendingPathComponent("/mlem/flairs")
            .appending(queryItems: [
                .init(name: "enabledOnly", value: enabledOnly.description)
            ])
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try jsonDecoder.decode([MlemFlair].self, from: data)
        
        flairs = .init(developers: .init(
            response
            .filter { [.activeDev, .inactiveDev].contains($0.flairType) }
            .map { $0.apId }
        ))
    }
}
