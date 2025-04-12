//
//  ZoomSliderLocation.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-02.
//

import Foundation
import Icons

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
    
    var icon: Icon {
        switch self {
        case .left: .general.backward
        case .right: .general.forward
        case .either: .settings.leftRight
        case .none: .general.circle
        }
    }
    
    var leftEnabled: Bool {
        switch self {
        case .left, .either: true
        default: false
        }
    }
    
    var rightEnabled: Bool {
        switch self {
        case .right, .either: true
        default: false
        }
    }
}
