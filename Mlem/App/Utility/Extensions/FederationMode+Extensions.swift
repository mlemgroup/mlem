//
//  FederationMode+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-30.
//  

import Foundation
import Theming
import MlemMiddleware

extension FederationMode {
    var label: LocalizedStringResource {
        switch self {
        case .all: "Yes"
        case .local: "Local Only"
        case .disable: "No"
        }
    }
    
    var color: ThemedColor {
        switch self {
        case .all: .themedPositive
        case .local: .themedWarning
        case .disable: .themedNegative
        }
    }
}
