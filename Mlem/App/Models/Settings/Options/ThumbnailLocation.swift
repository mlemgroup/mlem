//
//  ThumbnailLocation.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-23.
//

import Foundation
import Icons

enum ThumbnailLocation: String, CaseIterable, Codable {
    case left, right, none
    
    var label: LocalizedStringResource {
        switch self {
        case .none: "None"
        case .left: "Left"
        case .right: "Right"
        }
    }
    
    var icon: Icon {
        switch self {
        case .left: .general.backward
        case .right: .general.forward
        case .none: .general.hide
        }
    }
}
