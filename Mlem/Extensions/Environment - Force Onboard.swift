//
//  Environment - Force Onboard.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-19.
//

import Foundation
import SwiftUI

private struct ForceOnboardSetter: EnvironmentKey {
    static let defaultValue: () -> Void = { }
}

extension EnvironmentValues {
    var forceOnboard: () -> Void {
        get { self[ForceOnboardSetter.self] }
        set { self[ForceOnboardSetter.self] = newValue }
      }
}
