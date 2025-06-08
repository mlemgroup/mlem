//
//  Flairs.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-06-05.
//

public enum MlemFlairType: String, Codable {
    case activeDev, inactiveDev
}

struct MlemFlair: Codable {
    let apId: String
    let flairType: MlemFlairType
    let flairEnabled: Bool
}

public struct MlemFlairs {
    /// apIds of users who should have the Developer flair
    let developers: Set<String>
}
