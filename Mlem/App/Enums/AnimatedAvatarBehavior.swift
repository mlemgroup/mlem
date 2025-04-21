//
//  AnimatedAvatarBehavior.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-15.
//

import Foundation
import Icons

enum AnimatedAvatarBehavior: String, CaseIterable, Codable {
    case always, profile, never
    
    var label: LocalizedStringResource {
        switch self {
        case .always: "Always"
        case .profile: "Only in Profile"
        case .never: "Never"
        }
    }
    
    var icon: Icon {
        switch self {
        case .always: .general.success
        case .profile: .lemmy.person
        case .never: .general.failure
        }
    }
}
