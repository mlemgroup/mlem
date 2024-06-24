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
    var accessToken: String = "redacted"
    var siteVersion: SiteVersion?
    let username: String
    var storedNickname: String?
    let avatarUrl: URL?
    var lastUsed: Date? // nil when loading SavedAccounts from before this was added
    
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
        avatarUrl: URL? = nil,
        siteVersion: SiteVersion? = nil,
        lastUsed: Date? = nil
    ) {
        self.id = id
        self.instanceLink = instanceLink
        self.accessToken = accessToken
        self.username = username
        self.storedNickname = storedNickname
        self.avatarUrl = avatarUrl
        self.siteVersion = siteVersion
        self.lastUsed = .now
    }
    
    // Convenience initializer to create an equal copy with different non-identifying properties.
    init(
        from account: SavedAccount,
        accessToken: String? = nil,
        storedNickname: String? = nil,
        avatarUrl: URL? = nil,
        siteVersion: SiteVersion? = nil,
        lastUsed: Date? = nil
    ) {
        self.id = account.id
        self.instanceLink = account.instanceLink
        self.accessToken = accessToken ?? account.accessToken
        self.username = account.username
        self.storedNickname = storedNickname ?? account.storedNickname
        self.avatarUrl = avatarUrl ?? account.avatarUrl
        self.siteVersion = siteVersion ?? account.siteVersion
        self.lastUsed = lastUsed ?? account.lastUsed
    }
  
    // convenience
    var hostName: String? { instanceLink.host?.description }
    
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
        try container.encode(siteVersion, forKey: .siteVersion)
        try container.encode(lastUsed, forKey: .lastUsed)
    }
    
    static func == (lhs: SavedAccount, rhs: SavedAccount) -> Bool {
        lhs.id == rhs.id &&
            lhs.instanceLink == rhs.instanceLink &&
            lhs.username == rhs.username
    }
}

extension SavedAccount {
    /// Return the lowercased first letter of the nickname if it is a letter, otherwise returns "\*".
    var nameCategory: String {
        guard let first = nickname.first?.description.lowercased() else { return "Unknown" }
        if "abcdefghijklmnopqrstuvwxyz".contains(first) {
            return first
        }
        return "*"
    }
    
    /// Sort by instance and then by username
    var instanceSortKey: String {
        "\(instanceLink.host() ?? "unknown")\(nickname)"
    }
    
    // Sort by nickname and then by instance
    var nicknameSortKey: String {
        "\(nickname)\(instanceLink.host() ?? "unknown")"
    }
}
