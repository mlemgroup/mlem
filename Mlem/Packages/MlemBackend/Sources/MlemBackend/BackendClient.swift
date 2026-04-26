//
//  BackendClient.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-05-31.
//

import Foundation
import os
import Rest
import SwiftUI
import MlemLogger

public enum BackendEnvironment {
    case qualityControl, production
    
    var address: URL {
        switch self {
        case .production: .init(string: "https://backend.mlemapp.org:8443/")!
        case .qualityControl: .init(string: "https://backend.mlemapp.org:2096/")!
        }
    }
}

@Observable
public class BackendClient {
    let log: Logger = .mlemLogger()

    internal let restClient = RestClient(convertParamsToSnakeCase: false, decoder: .backendDecoder)
    
    public internal(set) var environment: BackendEnvironment = .production
    
    public internal(set) var flairs: MlemFlairs = .init(developers: .init())
    public internal(set) var testflightUpdate: URL?
    
    internal var baseUrl: URL { environment.address }
    
    public init() {
        refresh()
    }
    
    public func changeEnvironment(to environment: BackendEnvironment) {
        self.environment = environment
        refresh()
    }

    @discardableResult
    internal func perform<Request: RestRequest>(_ request: Request) async throws -> Request.Response {
        return try await restClient.perform(baseUrl: baseUrl, request, token: nil)
    }
    
    internal func refresh() {
        Task {
            do {
                try await fetchFlairs()
                try await fetchTestflightUpdate()
            } catch {
                log.error("\(error.localizedDescription)")
            }
        }
    }
}
