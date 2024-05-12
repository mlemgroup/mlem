//
//  EnvironmentValue+IsFirstPage.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import SwiftUI

private struct IsFirstPageKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isFirstPage: Bool {
        get { self[IsFirstPageKey.self] }
        set { self[IsFirstPageKey.self] = newValue }
    }
}
