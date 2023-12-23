//
//  EnvironmentValues+Navigation.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-21.
//

import Foundation
import SwiftUI

private struct NavigationEnvironmentKey: EnvironmentKey {
    static let defaultValue: Navigation? = nil
}

extension EnvironmentValues {
    var navigation: Navigation? {
        get { self[NavigationEnvironmentKey.self] }
        set { self[NavigationEnvironmentKey.self] = newValue }
    }
}
