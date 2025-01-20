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
        case .unspecified: "circle.lefthalf.filled"
        case .light: "circle"
        case .dark: "circle.fill"
        default: "circle.lefthalf.filled"
        }
    }
    
    static var optionCases: [UIUserInterfaceStyle] {
        [.unspecified, .light, .dark]
    }
}
