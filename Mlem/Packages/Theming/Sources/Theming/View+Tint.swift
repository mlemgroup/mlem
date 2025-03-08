//
//  File.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-07.
//

import SwiftUI

private struct ThemedTintViewModifier: ViewModifier {
    @Environment(\.palette) private var palette
    
    let themedShapeStyle: ThemedShapeStyle
    
    func body(content: Content) -> some View {
        content
            .tint(themedShapeStyle.resolve(with: palette))
    }
}

public extension View {
    func tint(_ themedShapeStyle: ThemedShapeStyle) -> some View {
        modifier(ThemedTintViewModifier(themedShapeStyle: themedShapeStyle))
    }
}
