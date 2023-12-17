//
//  EnvironmentValues+NavigationPath.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-16.
//

import Foundation
import SwiftUI

private struct NavigationPathGetter: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath> = .constant(NavigationPath())
}

extension EnvironmentValues {
    var navigationPath: Binding<NavigationPath> {
        get { self[NavigationPathGetter.self] }
        set { self[NavigationPathGetter.self] = newValue }
    }
}
