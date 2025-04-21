//
//  NsfwBlurBehavior.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-22.
//

import Icons
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
    
    var icon: Icon {
        switch self {
        case .always: .general.success
        case .outsideCommunity: .lemmy.community
        case .never: .general.failure
        }
    }
}
