//
//  InternetSpeed.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation

enum InternetSpeed: String, SettingsOptions {
    case slow, fast
    
    var label: String { rawValue.capitalized }
    
    var id: Self { self }
    
    var pageSize: Int {
        switch self {
        case .slow: return 25
        case .fast: return 10 // CHANGEME
        }
    }
}
