//
//  CommentJumpButtonLocation.swift
//  Mlem
//
//  Created by Sjmarf on 24/08/2024.
//

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
    
    var systemImage: String {
        switch self {
        case .bottomLeading: Icons.left
        case .bottomTrailing: Icons.right
        default: Icons.center
        }
    }
}
