//
//  ZoomDraggerLocation.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-02.
//

import Foundation

enum ZoomDraggerLocation: String, CaseIterable, Codable {
    case left, right, either, none
    
    var label: LocalizedStringResource {
        switch self {
        case .left: "Left"
        case .right: "Right"
        case .either: "Either"
        case .none: "Disabled"
        }
    }
}
