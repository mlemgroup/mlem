//
//  Navigation getter.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI

// MARK: - SwiftUI.NavigationPath

private struct NavigationPathGetter: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath> = .constant(NavigationPath())
}

extension EnvironmentValues {
    var navigationPath: Binding<NavigationPath> {
        get { self[NavigationPathGetter.self] }
        set { self[NavigationPathGetter.self] = newValue }
    }
}

// MARK: - Mlem NavigationRoute

private struct NavigationPathWithRoutes: EnvironmentKey {
    static let defaultValue: Binding<[AppRoute]> = .constant([])
}

extension EnvironmentValues {
    var navigationPathWithRoutes: Binding<[AppRoute]> {
        get { self[NavigationPathWithRoutes.self] }
        set { self[NavigationPathWithRoutes.self] = newValue }
    }
}

// MARK: - Navigation

private struct NavigationEnvironmentKey: EnvironmentKey {
    static let defaultValue: Navigation? = nil
}

extension EnvironmentValues {
    var navigation: Navigation? {
        get { self[NavigationEnvironmentKey.self] }
        set { self[NavigationEnvironmentKey.self] = newValue }
    }
}
