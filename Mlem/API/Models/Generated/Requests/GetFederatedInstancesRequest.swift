//
//  GetFederatedInstancesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetFederatedInstancesRequest: APIGetRequest {
    typealias Response = APIGetFederatedInstancesResponse

    let path = "/federated_instances"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
