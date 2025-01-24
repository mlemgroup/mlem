//
//  NsfwBlurBehavior.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-22.
//

import Foundation

enum NsfwBlurBehavior: String, CaseIterable, Codable {
    case always, outsideCommunity, never
    
    var label: LocalizedStringResource {
        switch self {
        case .always: "Always"
        case .outsideCommunity: "Outside NSFW Communities"
        case .never: "Never"
        }
    }
    
    var systemImage: String {
        switch self {
        case .always: Icons.successCircle
        case .outsideCommunity: Icons.communityCircle
        case .never: Icons.failureCircle
        }
    }
}
