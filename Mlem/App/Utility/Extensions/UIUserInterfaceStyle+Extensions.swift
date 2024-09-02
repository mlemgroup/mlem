//
//  UIUserInterfaceStyle+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-31.
//

import Foundation
import UIKit

extension UIUserInterfaceStyle {
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
    
    static var optionCases: [UIUserInterfaceStyle] {
        [.unspecified, .light, .dark]
    }
}
