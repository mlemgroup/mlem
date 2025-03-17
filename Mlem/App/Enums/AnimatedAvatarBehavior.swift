//
//  AnimatedAvatarBehavior.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-15.
//

import Foundation

enum AnimatedAvatarBehavior: String, CaseIterable, Codable {
    case always, profile, never
    
    var label: LocalizedStringResource {
        switch self {
        case .always: "Always"
        case .profile: "Only in Profile"
        case .never: "Never"
        }
    }
    
    var systemImage: String {
        switch self {
        case .always: Icons.successCircle
        case .profile: Icons.personCircle
        case .never: Icons.failureCircle
        }
    }
}
