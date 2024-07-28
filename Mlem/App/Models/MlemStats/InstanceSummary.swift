//
//  InstanceSummary.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

// The specification defined in https://github.com/mlemgroup/mlem-stats
struct InstanceSummary: Codable {
    let name: String
    let host: String
    let userCount: Int
    let avatar: URL?
    let version: SiteVersion
    
    var url: URL? { URL(string: "https://\(host)/") }
    
    var instanceStub: InstanceStub? {
        if let url {
            return .init(api: AppState.main.firstApi, actorId: url)
        }
        return nil
    }
}
