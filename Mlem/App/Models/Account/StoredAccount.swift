//
//  StoredAccount.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-13.
//

import Foundation
import MlemMiddleware

enum AccountError: Error {
    case noTokenInKeychain
}

struct StoredAccount: Codable {
    let actorId: URL
    let id: Int
    let name: String
    var storedNickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatar: URL?
    var lastUsed: Date?
    let baseUrl: URL
    
    enum CodingKeys: String, CodingKey {
        // These key names don't match the identifiers of their corresponding properties - this is because these key names must match the property names used in SavedAccount pre-1.3 in order to maintain compatibility
        case id, username, storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed
    }
    
    enum DecodingError: Error {
        case cannotRemoveExtraneousPathComponents
    }
    
    init(
        actorId: URL,
        id: Int,
        name: String,
        storedNickname: String? = nil,
        cachedSiteVersion: SiteVersion? = nil,
        avatar: URL? = nil,
        lastUsed: Date? = nil,
        baseUrl: URL
    ) {
        self.actorId = actorId
        self.id = id
        self.name = name
        self.storedNickname = storedNickname
        self.cachedSiteVersion = cachedSiteVersion
        self.avatar = avatar
        self.lastUsed = lastUsed
        self.baseUrl = baseUrl
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // copy simple values
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .username)
        self.storedNickname = try values.decode(String?.self, forKey: .storedNickname)
        self.cachedSiteVersion = try values.decode(SiteVersion?.self, forKey: .siteVersion)
        self.avatar = try values.decode(URL?.self, forKey: .avatarUrl)
        self.lastUsed = try values.decode(Date?.self, forKey: .lastUsed)

        // parse instance link
        let instanceLink = try values.decode(URL.self, forKey: .instanceLink)
        // Remove the "api/v3" path that we attached to the instanceLink pre-2.0
        var components = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
        components.path = ""
        guard let instanceLink = components.url else { throw DecodingError.cannotRemoveExtraneousPathComponents }
        self.baseUrl = instanceLink
        
        // parse actor id
        let actorId = parseActorId(instanceLink: instanceLink, name: name)
        self.actorId = actorId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .username)
        try container.encode(storedNickname, forKey: .storedNickname)
        try container.encode(cachedSiteVersion, forKey: .siteVersion)
        try container.encode(avatar, forKey: .avatarUrl)
        try container.encode(lastUsed, forKey: .lastUsed)
        try container.encode(baseUrl, forKey: .instanceLink)
    }
}

private func parseActorId(instanceLink: URL, name: String) -> URL {
    var actorComponents = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
    actorComponents.path = "/u/\(name)"
    return actorComponents.url!
}
