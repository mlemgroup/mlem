//
//  Saved Community.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

struct SavedAccount: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let instanceLink: URL
    let accessToken: String
    let username: String
  
    // convenience
    var hostName: String? { instanceLink.host?.description }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.instanceLink, forKey: .instanceLink)
        try container.encode("redacted", forKey: .accessToken)
        try container.encode(self.username, forKey: .username)
    }
}
