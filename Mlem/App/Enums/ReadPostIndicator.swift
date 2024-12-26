//
//  ReadPostIndicator.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-25.
//

import Foundation

enum ReadPostIndicator: String, CaseIterable, Codable {
    case outline, checkmark, none
    
    var label: LocalizedStringResource {
        switch self {
        case .outline: "Outline"
        case .checkmark: "Checkmark"
        case .none: "None"
        }
    }
}
