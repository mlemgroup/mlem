//
//  UIUserInterfaceStyle+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-31.
//

import Foundation
import Icons
import SwiftUI
import UIKit

extension UIUserInterfaceStyle: Codable {
    var label: String {
        switch self {
        case .unspecified:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        default:
            "Unknown"
        }
    }
    
    var icon: Icon {
        switch self {
        case .unspecified: .settings.systemMode
        case .light: .settings.lightMode
        case .dark: .settings.darkMode
        default: .settings.systemMode
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        default: nil
        }
    }
    
    static var optionCases: [UIUserInterfaceStyle] {
        [.unspecified, .light, .dark]
    }
}
