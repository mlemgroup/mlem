//
//  View - EasterFlags.swift
//  Mlem
//
//  Created by tht7 on 14/07/2023.
//

import Foundation
import SwiftUI

private struct EasterFlagSetter: EnvironmentKey {
    static let defaultValue: (_ flag: EasterFlag) -> Void = { _ in }
}

extension EnvironmentValues {
    var setEasterFlag: (_ flag: EasterFlag) -> Void {
        get { self[EasterFlagSetter.self] }
        set { self[EasterFlagSetter.self] = newValue }
    }
}
