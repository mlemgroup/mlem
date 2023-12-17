//
//  Navigation getter.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI

private struct NavigationPathWithRoutes: EnvironmentKey {
    static let defaultValue: Binding<[AppRoute]> = .constant([])
}

extension EnvironmentValues {
    var navigationPathWithRoutes: Binding<[AppRoute]> {
        get { self[NavigationPathWithRoutes.self] }
        set { self[NavigationPathWithRoutes.self] = newValue }
    }
}
