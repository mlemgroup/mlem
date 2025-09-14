//
//  File.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-09-11.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func glassProminentButtonStyle() -> some View {
        if #available(iOS 26, *) {
            buttonStyle(.glassProminent)
        } else {
            self
        }
    }
}
