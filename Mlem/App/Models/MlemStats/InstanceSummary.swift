//
//  InstanceSummary.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

// The specification defined in https://github.com/mlemgroup/mlem-stats
struct InstanceSummary: Codable, Hashable {
    let displayName: String
    let name: String
    let userCount: Int
    let avatar: URL?
    let version: SiteVersion
    
    enum CodingKeys: String, CodingKey {
        case displayName = "name"
        case name = "host"
        case userCount
        case avatar
        case version
    }

    var host: String { name }
    var url: URL? { URL(string: "https://\(host)/") }
    
    var instanceStub: InstanceStub? {
        if let url {
            return .init(api: AppState.main.firstApi, actorId: .instance(host: host))
        }
        return nil
    }
}
