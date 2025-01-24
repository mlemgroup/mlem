//
//  UIUserInterfaceStyle+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-31.
//

import Foundation
import SwiftUICore
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
    
    var systemImage: String {
        switch self {
        case .unspecified: Icons.systemMode
        case .light: Icons.lightMode
        case .dark: Icons.darkMode
        default: Icons.systemMode
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
