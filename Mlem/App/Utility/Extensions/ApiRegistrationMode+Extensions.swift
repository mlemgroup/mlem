//
//  ApiRegistrationMode+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import MlemMiddleware
import SwiftUI

extension ApiRegistrationMode {
    var label: LocalizedStringResource {
        switch self {
        case .closed: "Closed"
        case .requireApplication: "Requires Application"
        case .open: "Open"
        }
    }
    
    var color: Color {
        switch self {
        case .closed:
            return Palette.main.negative
        case .requireApplication:
            return Palette.main.caution
        case .open:
            return Palette.main.positive
        }
    }
}
