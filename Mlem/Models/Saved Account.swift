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
    let storedNickname: String?
    
    init(
        id: Int,
        instanceLink: URL,
        accessToken: String,
        username: String,
        storedNickname: String? = nil
    ) {
        self.id = id
        self.instanceLink = instanceLink
        self.accessToken = accessToken
        self.username = username
        self.storedNickname = storedNickname
    }
    
    /**
     Convenience initializer to create an equal copy with different non-identifying properties.
     */
    init(
        from account: SavedAccount,
        accessToken: String? = nil,
        storedNickname: String? = nil
    ) {
        self.id = account.id
        self.instanceLink = account.instanceLink
        self.accessToken = accessToken ?? account.accessToken
        self.username = account.username
        self.storedNickname = storedNickname ?? account.storedNickname
    }
  
    // convenience
    var hostName: String? { instanceLink.host?.description }
    
    /**
     If there is a nickname stored, returns that; otherwise returns the username
     */
    var nickname: String { storedNickname ?? username }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(instanceLink, forKey: .instanceLink)
        try container.encode("redacted", forKey: .accessToken)
        try container.encode(username, forKey: .username)
        try container.encode(storedNickname, forKey: .storedNickname)
    }
    
    static func == (lhs: SavedAccount, rhs: SavedAccount) -> Bool {
        lhs.id == rhs.id &&
            lhs.instanceLink == rhs.instanceLink &&
            lhs.username == rhs.username
    }
}
