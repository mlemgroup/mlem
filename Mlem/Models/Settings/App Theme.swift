//
//  App Theme.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-15.
//

import Foundation

enum PostFormat: String, SettingsOptions {
    var id: Self {
        return self
    }

    case light = "Light"
    case system = "System"
    case dark = "Dark"

    var label: String {
        get {
            self.rawValue
        }
    }
}
