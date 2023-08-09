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
    var storedNickname: String?
    
    init(id: Int,
         instanceLink: URL,
         accessToken: String,
         username: String,
         storedNickname: String? = nil) {
        self.id = id
        self.instanceLink = instanceLink
        self.accessToken = accessToken
        self.username = username
        self.storedNickname = storedNickname
    }
  
    // convenience
    var hostName: String? { instanceLink.host?.description }
    
    /**
     If there is a nickname stored, returns that; otherwise returns the username
     */
    var nickname: String { storedNickname ?? username }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.instanceLink, forKey: .instanceLink)
        try container.encode("redacted", forKey: .accessToken)
        try container.encode(self.username, forKey: .username)
    }
    
    static func == (lhs: SavedAccount, rhs: SavedAccount) -> Bool {
        return lhs.id == rhs.id &&
        lhs.instanceLink == rhs.instanceLink &&
        lhs.username == rhs.username
    }
}
