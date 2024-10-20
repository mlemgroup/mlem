//
//  Form.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI

/// Identical to Form, but respects Palette
struct Form<Content: View>: View {
    @Environment(Palette.self) var palette
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        SwiftUI.Form {
            content()
                .foregroundStyle(palette.primary)
                .listRowBackground(palette.secondaryGroupedBackground)
                .tint(palette.accent)
                .buttonStyle(PaletteButton())
        }
        .listStyle(InsetListStyle())
        .scrollContentBackground(.hidden)
        .background(palette.groupedBackground)
        .shadow(color: palette.primary.opacity(palette.bordered ? 0.2 : 0.0), radius: 5)
    }
}
