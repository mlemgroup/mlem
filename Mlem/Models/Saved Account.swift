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
    let avatarUrl: URL?
    
    var stableIdString: String {
        assert(instanceLink.host() != nil, "nil instance link host!")
        return "\(username)@\(instanceLink.host() ?? "unknown")"
    }
    
    init(
        id: Int,
        instanceLink: URL,
        accessToken: String,
        username: String,
        storedNickname: String? = nil,
        avatarUrl: URL? = nil
    ) {
        self.id = id
        self.instanceLink = instanceLink
        self.accessToken = accessToken
        self.username = username
        self.storedNickname = storedNickname
        self.avatarUrl = avatarUrl
    }
    
    // Convenience initializer to create an equal copy with different non-identifying properties.
    init(
        from account: SavedAccount,
        accessToken: String? = nil,
        storedNickname: String? = nil,
        avatarUrl: URL?
    ) {
        self.id = account.id
        self.instanceLink = account.instanceLink
        self.accessToken = accessToken ?? account.accessToken
        self.username = account.username
        self.storedNickname = storedNickname ?? account.storedNickname
        self.avatarUrl = avatarUrl
    }
  
    // convenience
    var hostName: String? {
        if let host = instanceLink.host()?.description, host != "localhost" {
            return host
        } else {
            // for localhost, removes `/api/vX` from link string
            return String(instanceLink.absoluteString.dropLast(7))
        }
    }
    
    /// If there is a nickname stored, returns that; otherwise returns the username
    var nickname: String { storedNickname ?? username }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(instanceLink, forKey: .instanceLink)
        try container.encode("redacted", forKey: .accessToken)
        try container.encode(username, forKey: .username)
        try container.encode(storedNickname, forKey: .storedNickname)
        try container.encode(avatarUrl, forKey: .avatarUrl)
    }
    
    static func == (lhs: SavedAccount, rhs: SavedAccount) -> Bool {
        lhs.id == rhs.id &&
            lhs.instanceLink == rhs.instanceLink &&
            lhs.username == rhs.username
    }
}
