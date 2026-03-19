//
//  BackendHealthCheckRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Rest

internal struct BackendHealthCheckRequest: GetRequest {
    public typealias Parameters = Never
    public typealias Response = BackendHealthCheck
    
    public let path: String = "v0/health"
    public let parameters: Parameters? = nil
}
