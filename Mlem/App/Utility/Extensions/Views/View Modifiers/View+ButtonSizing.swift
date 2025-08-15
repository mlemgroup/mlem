//
//  View+ButtonSizing.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-15.
//

import SwiftUI

// swiftlint:disable:next type_name
enum ButtonSizing_ {
    case automatic, flexible, fitted
    
    @available(iOS 26, *)
    var swiftUiValue: ButtonSizing {
        switch self {
        case .automatic: .automatic
        case .flexible: .flexible
        case .fitted: .fitted
        }
    }
}

extension View {
    @ViewBuilder
    func buttonSizing_(_ sizing: ButtonSizing_) -> some View {
        if #available(iOS 26, *) {
            buttonSizing(sizing.swiftUiValue)
        } else {
            self
        }
    }
}
