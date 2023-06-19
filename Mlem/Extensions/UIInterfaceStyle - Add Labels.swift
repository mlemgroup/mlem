//
//  UIInterfaceStyle - Add Labels.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-15.
//

import Foundation
import SwiftUI

extension UIUserInterfaceStyle: SettingsOptions {
    public var id: Self { self }// RawValue { rawValue }
    
    public static var allCases: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
    
    var label: String {
        switch(self) {
        case .unspecified:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        default:
            return "UNKNOWN, PLEASE REPORT THIS AS A BUG"
        }
    }
    
//    var icon: Image? {
//        switch(self) {
//        case .light:
//            return Image(systemName: "sun.max")
//        case .unspecified:
//            return Image(systemName: "circle.righthalf.filled")
//        case .dark:
//            return Image(systemName: "moon")
//        default:
//            return Image(systemName: "exclamationmark.triangle")
//        }
//    }
}
