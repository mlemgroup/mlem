//
//  CommentJumpButtonLocation.swift
//  Mlem
//
//  Created by Sjmarf on 24/08/2024.
//

import Icons
import SwiftUI

enum CommentJumpButtonLocation: String, CaseIterable, Codable {
    case bottomLeading, bottomTrailing, bottomCenter, none
    
    var alignment: Alignment {
        switch self {
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        case .bottomCenter: .bottom
        case .none: .bottomTrailing
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .bottomLeading: "Left"
        case .bottomTrailing: "Right"
        case .bottomCenter: "Center"
        case .none: "Hidden"
        }
    }
    
    var icon: Icon {
        switch self {
        case .bottomLeading: .general.backward
        case .bottomTrailing: .general.forward
        default: .settings.center
        }
    }
}
