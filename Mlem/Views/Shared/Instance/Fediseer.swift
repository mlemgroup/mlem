//
//  Fediseer.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

// https://fediseer.com/api/v1/whitelist/lemmy.world

struct FediseerInstance: Codable {
    let id: Int
    // let domain: String
    // let software: String
    let claimed: Int
    let approvals: Int // This is the number of endorsements given
    let endorsements: Int // This is the number of endorsements received
    let guarantor: String?
    
    // Fediseer lets instances admins self-report these values
    let sysadmins: Int
    let moderators: Int
}
