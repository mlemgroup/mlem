//
//  InstanceSummary.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-06-01.
//

import Foundation

// The specification defined in https://github.com/mlemgroup/mlem-backend
public struct InstanceSummary: Codable, Hashable, Identifiable {
    public let displayName: String
    public let name: String
    public let userCount: Int
    public let avatar: URL?
    public let software: SiteSoftware
    
    public init(
        displayName: String,
        name: String,
        userCount: Int,
        avatar: URL? = nil,
        software: SiteSoftware
    ) {
        self.displayName = displayName
        self.name = name
        self.userCount = userCount
        self.avatar = avatar
        self.software = software
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName = "name"
        case name = "host"
        case userCount
        case avatar
        case version // Removed in Mlem 2.2
        case software
    }

    public var host: String { name }
    public var url: URL? { URL(string: "https://\(host)/") }
    
    public var id: String { host }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.name = try container.decode(String.self, forKey: .name)
        self.userCount = try container.decode(Int.self, forKey: .userCount)
        self.avatar = try container.decode(URL?.self, forKey: .avatar)
        
        if let software = try container.decodeIfPresent(SiteSoftware.self, forKey: .software) {
            self.software = software
        } else if let version = try container.decodeIfPresent(SiteVersion.self, forKey: .version) {
            self.software = .init(type: .lemmy, version: version)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .software, in: container, debugDescription: "")
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(name, forKey: .name)
        try container.encode(userCount, forKey: .userCount)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(software, forKey: .software)
    }
}
