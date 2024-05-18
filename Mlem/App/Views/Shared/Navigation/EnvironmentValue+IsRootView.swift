//
//  EnvironmentValue+IsRootView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import SwiftUI

private struct IsRootViewKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isRootView: Bool {
        get { self[IsRootViewKey.self] }
        set { self[IsRootViewKey.self] = newValue }
    }
}
