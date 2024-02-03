//
//  AppLock.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-16.
//

import Foundation

enum AppLock: String, SettingsOptions {
    case disabled, instant
    
    var label: String { rawValue.capitalized }
    
    var id: Self { self }
    
    var timeOut: Int {
        switch self {
        case .disabled: return -1
        case .instant: return 0
        }
    }
}
