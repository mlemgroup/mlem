//
//  APIFederatedInstances.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023
//

import Foundation

// lemmy_api_common::site::FederatedInstances
struct APIFederatedInstances: Decodable {
    let linked: [String]
    let allowed: [String]?
    let blocked: [String]?
}
