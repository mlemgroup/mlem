//
//  UptimeData.swift
//  Mlem
//
//  Created by Sjmarf on 28/01/2024.
//

import Foundation

struct UptimeData: Codable {
    let results: [UptimeResponseTime]
    let events: [UptimeEvent]
//        let url1 = URL(string: "https://hws.dev/user-24601.json")!
//            let user = try await URLSession.shared.decode(User.self, from: url1)
}

struct UptimeResponseTime: Codable, Identifiable {
    let success: Bool
    let duration: Int
    let timestamp: Date
    
    var id: Int { Int(timestamp.timeIntervalSince1970) }
}

struct UptimeEvent: Codable {
    enum EventType: String, Codable {
        case healthy = "HEALTHY"
        case unhealthy = "UNHEALTHY"
    }
    
    let type: EventType
    let timestamp: Date
}
