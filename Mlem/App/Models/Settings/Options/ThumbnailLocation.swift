//
//  ThumbnailLocation.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-23.
//

import Foundation

enum ThumbnailLocation: String, CaseIterable, Codable {
    case left, right, none
    
    var label: LocalizedStringResource {
        switch self {
        case .left: "Left"
        case .right: "Right"
        case .none: "None"
        }
    }
}
