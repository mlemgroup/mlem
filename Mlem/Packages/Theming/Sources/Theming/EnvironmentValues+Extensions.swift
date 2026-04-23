//
//  File.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var palette: Palette = .default
    @Entry var tint: ThemedColor = .themedAccent
}

public extension View {
    func palette(_ palette: Palette) -> some View {
        environment(\.palette, palette)
    }
}
