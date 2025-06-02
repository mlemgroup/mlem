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
    public let version: SiteVersion
    
    public init(displayName: String, name: String, userCount: Int, avatar: URL? = nil, version: SiteVersion) {
        self.displayName = displayName
        self.name = name
        self.userCount = userCount
        self.avatar = avatar
        self.version = version
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName = "name"
        case name = "host"
        case userCount
        case avatar
        case version
    }

    public var host: String { name }
    public var url: URL? { URL(string: "https://\(host)/") }
    
    public var id: String { host }
}
