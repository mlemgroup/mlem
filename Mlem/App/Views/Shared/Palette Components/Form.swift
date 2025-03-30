//
//  Form.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI
import Theming

/// Identical to Form, but respects Palette
struct Form<Content: View>: View {
    @Environment(\.palette) var palette
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        SwiftUI.Form {
            content()
                .foregroundStyle(.themedPrimary)
                .listRowBackground(palette.groupedBackground.secondary)
                .tint(.themedAccent)
                .buttonStyle(PaletteButton())
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ThemedColor.themedGroupedBackground.ignoresSafeArea())
        .shadow(color: palette.label.primary.opacity(palette.bordered ? 0.4 : 0.0), radius: 1)
    }
}
