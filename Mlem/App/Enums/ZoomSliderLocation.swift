//
//  ZoomSliderLocation.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-02.
//

import Foundation

enum ZoomSliderLocation: String, CaseIterable, Codable {
    case left, right, either, none
    
    var label: LocalizedStringResource {
        switch self {
        case .left: "Left"
        case .right: "Right"
        case .either: "Either"
        case .none: "Disabled"
        }
    }
    
    var systemImage: String {
        switch self {
        case .left: Icons.left
        case .right: Icons.right
        case .either: Icons.leftAndRightCircle
        case .none: Icons.absent
        }
    }
}
