//
//  InstanceMetadata+Mock.swift
//  Mlem
//
//  Created by mormaer on 28/08/2023.
//
//

import Foundation

extension InstanceMetadata {
    static func mock(
        name: String = "Example Instance",
        url: URL,
        newUsers: Bool = true,
        newCommunities: Bool = true,
        federated: Bool = true,
        adult: Bool = true,
        downvotes: Bool = true,
        users: Int = 1234,
        blocking: Int = 0,
        blockedBy: Int = 0,
        uptime: String = "99%",
        version: String = "0.18.4"
    ) -> InstanceMetadata {
        .init(
            name: name,
            url: url,
            newUsers: newUsers,
            newCommunities: newCommunities,
            federated: federated,
            adult: adult,
            downvotes: downvotes,
            users: users,
            blocking: blocking,
            blockedBy: blockedBy,
            uptime: uptime,
            version: version
        )
    }
}
