//
//  File.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var palette: Palette = .default
}

public extension View {
    func palette(_ palette: Palette) -> some View {
        environment(\.palette, palette)
    }
}
