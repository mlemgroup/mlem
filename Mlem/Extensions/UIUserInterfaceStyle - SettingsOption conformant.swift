//
//  UIUserInterfaceStyle - SettingsOption conformant.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

import SwiftUI

extension UIUserInterfaceStyle: SettingsOptions {
    public static var allCases: [UIUserInterfaceStyle] {
        return [.light, .unspecified, .dark]
    }

    var label: String {
        switch self {
        case .light:
            return "Light"
        case .unspecified:
            return "System"
        case .dark:
            return "Dark"
        @unknown default:
            assertionFailure("A new case has been added which we are not handling")
            return "Unknown"
        }
    }

    public var id: Self { self }
}
