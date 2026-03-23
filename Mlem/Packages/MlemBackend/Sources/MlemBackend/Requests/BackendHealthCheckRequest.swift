//
//  BackendHealthCheckRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Rest

internal struct BackendHealthCheckRequest: GetRequest {
    typealias Parameters = Never
    typealias Response = BackendHealthCheck
    
    let path: String = "v0/health"
    let parameters: Parameters? = nil
}
