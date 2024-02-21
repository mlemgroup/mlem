//
//  GetFederatedInstancesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetFederatedInstancesRequest: ApiGetRequest {
    typealias Response = ApiGetFederatedInstancesResponse

    let path = "/federated_instances"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
