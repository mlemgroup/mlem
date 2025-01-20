//
//  UIUserInterfaceStyle+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-31.
//

import Foundation
import UIKit
import SwiftUICore

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
    
    static var optionCases: [UIUserInterfaceStyle] {
        [.unspecified, .light, .dark]
    }
}
