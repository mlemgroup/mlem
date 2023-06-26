//
//  File.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI

private struct NavigationPathGetter: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath>? = nil
}

extension EnvironmentValues {
    var navigationPath: Binding<NavigationPath>? {
        get { self[NavigationPathGetter.self] }
        set { self[NavigationPathGetter.self] = newValue }
      }
}
