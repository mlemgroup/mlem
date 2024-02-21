//
//  InstanceMetadata.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-16.
//

import Foundation

struct InstanceMetadata: Codable {
    let name: String
    let url: URL
    let newUsers: Bool
    let newCommunities: Bool
    let federated: Bool
    let adult: Bool
    let downvotes: Bool
    let users: Int
    let blocking: Int
    let blockedBy: Int
    let uptime: String
    let version: String
}

extension InstanceMetadata: Identifiable, Equatable {
    var id: String { url.description }
}
