//
//  Fediseer.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

// https://fediseer.com/api/v1/whitelist/lemmy.world

struct FediseerData {
    var instance: FediseerInstance
    var endorsements: [FediseerEndorsement]?
    
    var topEndorsements: [FediseerEndorsement] {
        if var endorsements {
            endorsements = endorsements.sorted { $0.hasReason && !$1.hasReason }
            return endorsements
        }
        return []
    }
}

struct FediseerInstance: Codable {
    let id: Int
    // let domain: String
    // let software: String
    let claimed: Int
    let approvals: Int // This is the number of endorsements given
    let endorsements: Int // This is the number of endorsements received
    let guarantor: String?
    
    // Fediseer lets instances admins self-report these values
    let sysadmins: Int?
    let moderators: Int?
}

struct FediseerEndorsements: Codable {
    let instances: [FediseerEndorsement]
}

struct FediseerEndorsement: Codable {
    let domain: String
    let endorsementReasons: [String]?
    
    var hasReason: Bool { !(endorsementReasons?.isEmpty ?? true) }
    
    var formattedReason: String? {
        if let reason = endorsementReasons?.first {
            return "- \(reason.split(separator: ",").joined(separator: "\n- "))"
        }
        return nil
    }
    
    var instanceModel: InstanceModel? {
        do {
            return try .init(domainName: domain)
        } catch {
            return nil
        }
    }
}
