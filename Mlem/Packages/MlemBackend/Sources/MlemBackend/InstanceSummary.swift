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
    public let totalUsers: Int
    public let avatar: URL?
    public let software: InstanceSummarySoftware
    
    public init(
        displayName: String,
        name: String,
        totalUsers: Int,
        avatar: URL? = nil,
        software: InstanceSummarySoftware
    ) {
        self.displayName = displayName
        self.name = name
        self.totalUsers = totalUsers
        self.avatar = avatar
        self.software = software
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName = "name"
        case name = "host"
        case userCount // Removed in Mlem 2.4
        case totalUsers
        case avatar
        case software
    }

    public var host: String { name }
    public var url: URL? { URL(string: "https://\(host)/") }
    
    public var id: String { host }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.name = try container.decode(String.self, forKey: .name)
        
        if let totalUsers = try container.decodeIfPresent(Int.self, forKey: .totalUsers) {
            self.totalUsers = totalUsers
        } else if let totalUsers = try container.decodeIfPresent(Int.self, forKey: .userCount) {
            self.totalUsers = totalUsers
        } else {
            throw DecodingError.dataCorruptedError(forKey: .totalUsers, in: container, debugDescription: "")
        }
        
        self.avatar = try container.decode(URL?.self, forKey: .avatar)
        self.software = try container.decode(InstanceSummarySoftware.self, forKey: .software)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(name, forKey: .name)
        try container.encode(totalUsers, forKey: .totalUsers)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(software, forKey: .software)
    }
}
