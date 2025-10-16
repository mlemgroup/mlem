//
//  File.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-07.
//

import SwiftUI

private struct ThemedTintViewModifier: ViewModifier {
    @Environment(\.palette) private var palette
    
    let themedColor: ThemedColor
    
    func body(content: Content) -> some View {
        content
            .tint(themedColor.resolve(with: palette))
    }
}

public extension View {
    @ViewBuilder
    func tint(_ themedColor: ThemedColor?) -> some View {
        if let themedColor {
            modifier(ThemedTintViewModifier(themedColor: themedColor))
        } else {
            self
        }
    }
}

private struct ThemedGradientTintModifier: ViewModifier {
    @Environment(\.palette) private var palette
    
    let themedColor: ThemedColor
    
    func body(content: Content) -> some View {
        content
            .tint(themedColor.gradient(palette: palette))
    }
}

public extension View {
    func gradientTint(_ themedColor: ThemedColor) -> some View {
        modifier(ThemedGradientTintModifier(themedColor: themedColor))
    }
}
