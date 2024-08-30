//
//  PaletteForm.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI

/// Identical to Form, but respects Palette
struct PaletteForm<Content: View>: View {
    @Environment(Palette.self) var palette
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Form {
            content()
                .foregroundStyle(palette.primary)
                .listRowBackground(palette.secondaryGroupedBackground)
        }
        .scrollContentBackground(.hidden)
        .background(palette.groupedBackground)
    }
}
