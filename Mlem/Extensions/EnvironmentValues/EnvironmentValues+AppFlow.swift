//
//  EnvironmentValues+AppFlow.swift
//  Mlem
//
//  Created by mormaer on 08/09/2023.
//
//

import SwiftUI

private struct AppFlowSetter: EnvironmentKey {
    static let defaultValue: (AppFlow) -> Void = { _ in }
}

extension EnvironmentValues {
    var setAppFlow: (AppFlow) -> Void {
        get { self[AppFlowSetter.self] }
        set { self[AppFlowSetter.self] = newValue }
    }
}
