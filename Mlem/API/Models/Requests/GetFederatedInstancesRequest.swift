//
//  GetFederatedInstancesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetFederatedInstancesRequest: APIGetRequest {
    typealias Response = APIGetFederatedInstancesResponse

    let path = "/federated_instances"
    let queryItems: [URLQueryItem]

    init() {
        var request: REQUEST_TYPE = BODY_INIT
        self.queryItems = .init()
    }
}
