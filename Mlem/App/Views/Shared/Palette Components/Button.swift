//
//  Button.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-06.
//

import Foundation
import SwiftUI

struct PaletteButton: ButtonStyle {
    @Environment(Palette.self) var palette
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        if isEnabled {
            configuration.label
                .foregroundStyle(.tint)
        } else {
            configuration.label
                .foregroundStyle(palette.secondary)
        }
    }
}
