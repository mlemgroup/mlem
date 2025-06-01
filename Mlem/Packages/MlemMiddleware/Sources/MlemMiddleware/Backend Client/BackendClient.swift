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
    
    public var mlemDevelopers: [String: Bool] = .init()
    
    public static var main: BackendClient = .init()

    private init() {
        guard let url = URL(string: backendAddress) else {
            fatalError("Could not form backend URL")
        }
        baseUrl = url
        
        Task {
            do {
                try await fetchDevelopers()
            } catch {
                print(error)
            }
        }
    }
    
    public func healthcheck() async throws -> Bool {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/health")))
        return try JSONDecoder().decode(Bool.self, from: data)
    }
    
    private func fetchDevelopers() async throws {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseUrl.appendingPathComponent("/mlem/developers")))
        let response = try JSONDecoder().decode([MlemDeveloper].self, from: data)
        
        // convert to map for faster key lookup
        mlemDevelopers = response.reduce(into: [String: Bool]()) { result, developer in
            result[developer.apId] = developer.active
        }
    }
}
