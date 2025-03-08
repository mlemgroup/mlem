//
//  ApiRegistrationMode+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

extension ApiRegistrationMode {
    var label: LocalizedStringResource {
        switch self {
        case .closed: "Closed"
        case .requireApplication: "Requires Application"
        case .open: "Open"
        }
    }
    
    var color: ThemedColor {
        switch self {
        case .closed: .themedNegative
        case .requireApplication: .themedCaution
        case .open: .themedPositive
        }
    }
}
