//
//  File.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
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

private struct CustomNavigationPath: EnvironmentKey {
    static let defaultValue: Binding<[MlemRoutes]> = .constant([])
}

extension EnvironmentValues {
    var customNavigationPath: Binding<[MlemRoutes]> {
        get { self[CustomNavigationPath.self] }
        set { self[CustomNavigationPath.self] = newValue }
    }
}
