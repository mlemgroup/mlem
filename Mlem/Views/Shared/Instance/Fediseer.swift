//
//  Fediseer.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation
import SwiftUI

// https://fediseer.com/api/v1/whitelist/lemmy.world

struct FediseerData {
    var instance: FediseerInstance
    var endorsements: [FediseerEndorsement]?
    var hesitations: [FediseerHesitation]?
    var censures: [FediseerCensure]?
    
    var topEndorsements: [FediseerEndorsement] {
        if var endorsements {
            endorsements = endorsements.sorted { $0.reason != nil && $1.reason == nil }
            return endorsements
        }
        return []
    }
    
    func numberOf(_ opinionType: FediseerOpinionType) -> Int {
        switch opinionType {
        case .endorsement:
            endorsements?.count ?? 0
        case .hesitation:
            hesitations?.count ?? 0
        case .censure:
            censures?.count ?? 0
        }
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

struct FediseerHesitations: Codable {
    let instances: [FediseerHesitation]
}

struct FediseerCensures: Codable {
    let instances: [FediseerCensure]
}

enum FediseerOpinionType: CaseIterable, Identifiable {
    case endorsement, hesitation, censure
    
    var id: FediseerOpinionType { self }
}

protocol FediseerOpinion {
    var domain: String { get }
    var reason: String? { get }
    var evidence: String? { get }
    
    static var systemImage: String { get }
    static var color: Color { get }
}

extension FediseerOpinion {
    var instanceModel: InstanceModel? {
        do {
            return try .init(domainName: domain)
        } catch {
            return nil
        }
    }
    
    var formattedReason: String? {
        if let reason {
            return "- \(reason.split(separator: ",").joined(separator: "\n- "))"
        }
        return nil
    }
}

struct FediseerEndorsement: Codable {
    let domain: String
    let endorsementReasons: [String]?
}

extension FediseerEndorsement: FediseerOpinion {
    static var systemImage: String = Icons.fediseerEndorsement
    static var color: Color = .teal
    
    var reason: String? { endorsementReasons?.first }
    var evidence: String? { nil }
}

struct FediseerHesitation: Codable {
    let domain: String
    let hesitationReasons: [String]?
    let hesitationEvidence: [String]?
}

extension FediseerHesitation: FediseerOpinion {
    static var systemImage: String = Icons.fediseerHesitation
    static var color: Color = .orange
    
    var reason: String? { hesitationReasons?.first }
    var evidence: String? { hesitationEvidence?.first }
}

struct FediseerCensure: Codable {
    let domain: String
    let censureReasons: [String]?
    let censureEvidence: [String]?
}

extension FediseerCensure: FediseerOpinion {
    static var systemImage: String = Icons.fediseerCensure
    static var color: Color = .red
    
    var reason: String? { censureReasons?.first }
    var evidence: String? { censureEvidence?.first }
}
