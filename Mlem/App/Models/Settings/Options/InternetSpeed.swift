//
//  InternetSpeed.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation

enum InternetSpeed: String, Codable {
    case debug, slow, fast
    
    var label: LocalizedStringResource {
        switch self {
        case .debug: "Debug"
        case .slow: "Slow"
        case .fast: "Fast"
        }
    }
    
    var id: Self { self }
    
    var pageSize: Int {
        switch self {
        case .debug: return 11
        case .slow: return 25
        case .fast: return 50
        }
    }
}
