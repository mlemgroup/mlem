//
//  APIClient+Dependency.swift
//  Mlem
//
//  Created by mormaer on 14/07/2023.
//
//

import Dependencies
import Foundation

extension APIClient: DependencyKey {
    static let liveValue = APIClient(transport: { urlSession, urlRequest in try await urlSession.data(for: urlRequest) })
    static let testValue = APIClient(transport: unimplemented())
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
