//
//  Fediseer.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import MlemMiddleware
import SwiftUI

// https://fediseer.com/api/v1/whitelist/lemmy.world

struct FediseerData: Hashable, Equatable {
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
    
    func opinions(ofType type: FediseerOpinionType) -> [any FediseerOpinion] {
        switch type {
        case .endorsement:
            endorsements ?? []
        case .hesitation:
            hesitations ?? []
        case .censure:
            censures ?? []
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(instance.domain)
    }
}

struct FediseerInstance: Codable, Equatable {
    let id: Int
    let domain: String
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
    var instances: [FediseerEndorsement] = .init()
}

struct FediseerHesitations: Codable {
    var instances: [FediseerHesitation] = .init()
}

struct FediseerCensures: Codable {
    var instances: [FediseerCensure] = .init()
}

enum FediseerOpinionType: CaseIterable, Identifiable {
    case endorsement, hesitation, censure
    
    var id: FediseerOpinionType { self }
    
    var label: String {
        switch self {
        case .endorsement: .init(localized: "Endorsements")
        case .hesitation: .init(localized: "Hesitations")
        case .censure: .init(localized: "Censures")
        }
    }
}

protocol FediseerOpinion {
    var domain: String { get }
    var reason: String? { get }
    var evidence: String? { get }
    
    static var systemImage: String { get }
    static var color: Color { get }
}

extension FediseerOpinion {
    var instanceStub: InstanceStub? {
        guard let url = URL(string: "https://\(domain)") else { return nil }
        return .init(api: .getApiClient(for: url, with: nil), actorId: url)
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

extension FediseerEndorsement: FediseerOpinion, Equatable {
    static var systemImage: String = Icons.fediseerEndorsement
    static var color: Color { Palette.main.colorfulAccent(7) }
    
    var reason: String? { endorsementReasons?.first }
    var evidence: String? { nil }
}

struct FediseerHesitation: Codable {
    let domain: String
    let hesitationReasons: [String]?
    let hesitationEvidence: [String]?
}

extension FediseerHesitation: FediseerOpinion, Equatable {
    static var systemImage: String = Icons.fediseerHesitation
    static var color: Color { Palette.main.caution }
    
    var reason: String? { hesitationReasons?.first }
    var evidence: String? { hesitationEvidence?.first }
}

struct FediseerCensure: Codable {
    let domain: String
    let censureReasons: [String]?
    let censureEvidence: [String]?
}

extension FediseerCensure: FediseerOpinion, Equatable {
    static var systemImage: String = Icons.fediseerCensure
    static var color: Color { Palette.main.warning }
    
    var reason: String? { censureReasons?.first }
    var evidence: String? { censureEvidence?.first }
}
