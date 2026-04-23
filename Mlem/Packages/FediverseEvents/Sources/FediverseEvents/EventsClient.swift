//
//  File.swift
//  FediverseEvents
//
//  Created by Sjmarf on 2026-04-21.
//  

import Foundation
import Observation
import Rest

public enum EventsEnvironment {
    case qualityControl, production
    
    var address: URL {
        switch self {
        case .production: .init(string: "https://api.fediverse.events")!
        case .qualityControl: .init(string: "https://test-api.fediverse.events")!
        }
    }
}

@Observable
public final class EventsClient {
    internal let restClient = RestClient(convertParamsToSnakeCase: false, decoder: .defaultDecoder)

    public internal(set) var environment: EventsEnvironment = .production

    internal var baseUrl: URL { environment.address }

    public init() {}

    public func changeEnvironment(to environment: EventsEnvironment) {
        self.environment = environment
    }

    @discardableResult
    internal func perform<Request: RestRequest>(_ request: Request) async throws -> Request.Response {
        return try await restClient.perform(baseUrl: baseUrl, request, token: nil)
    }
}
