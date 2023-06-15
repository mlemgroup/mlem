//
//  Settings Options.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-15.
//

import Foundation

/// SettingsOptions is the protocol you should conform to in order to use the `SelectableSwitchableSettingsItem`.
/// See the App Theme implementation as an example.
protocol SettingsOptions: Codable, CaseIterable, Hashable, Identifiable {
    var label: String { get }
}
