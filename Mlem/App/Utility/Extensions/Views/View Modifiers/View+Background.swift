//
//  View+Background.swift
//  Mlem
//
//  Created by Sjmarf on 2025-04-01.
//

import SwiftUI
import Theming

extension View {
    func themedGroupedBackground() -> some View {
        background(ThemedColor.themedGroupedBackground)
            .background(ThemedColor.themedGroupedBackground.ignoresSafeArea(.keyboard))
    }
}
