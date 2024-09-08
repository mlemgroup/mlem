//
//  InternetSpeed.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation

enum InternetSpeed: String, SettingsOptions, Codable {
    case debug, slow, fast
    
    var label: String { rawValue.capitalized }
    
    var id: Self { self }
    
    var pageSize: Int {
        switch self {
        case .debug: return 11
        case .slow: return 25
        case .fast: return 50
        }
    }
}
