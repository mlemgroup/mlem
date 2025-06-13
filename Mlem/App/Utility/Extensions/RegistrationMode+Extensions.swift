//
//  ApiRegistrationMode+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

extension RegistrationMode {
    var label: LocalizedStringResource {
        switch self {
        case .closed: "Closed"
        case .requiresApplication: "Requires Application"
        case .open: "Open"
        }
    }
    
    var color: ThemedColor {
        switch self {
        case .closed: .themedNegative
        case .requiresApplication: .themedCaution
        case .open: .themedPositive
        }
    }
}
