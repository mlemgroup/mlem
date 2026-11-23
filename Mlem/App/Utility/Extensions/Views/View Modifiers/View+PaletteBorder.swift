//
//  View+PaletteBorder.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-10-10.
//

import Foundation
import SwiftUI
import Theming

private struct PaletteBorder: ViewModifier {
    @Environment(\.palette) var palette
    
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if palette.bordered {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.themedDivider, lineWidth: 0.5)
                }
            }
    }
}

private struct UnselectedPostPalette: ViewModifier {
    @Environment(\.palette) var palette
    @Environment(\.unselectedPostPalette) var unselectedPostPalette

    var inset: CGFloat

    func body(content: Content) -> some View {
        content
            .palette(unselectedPostPalette ?? palette)
            .background {
                ConcentricRectangle(
                    corners: .concentric(minimum: .fixed(Constants.main.barIconCornerRadius)),
                    isUniform: true
                )
                .fill(unselectedPostPalette?.groupedBackground.secondary ?? .clear)
                .padding(inset)
            }
    }
}

extension EnvironmentValues {
    @Entry var unselectedPostPalette: Palette?
}

extension Palette {
    var selectedPost: Palette {
        var palette = self
        palette.groupedBackground.secondary = accent
        palette.label = .init(
            primary: contrastingLabel,
            secondary: contrastingLabel.opacity(0.8),
            tertiary: contrastingLabel.opacity(0.6)
        )
        palette.accent = contrastingLabel
        return palette
    }
}

extension View {
    /// Applies a rounded rect border to the view if the current palette `.bordered` is `true`
    func paletteBorder(cornerRadius: CGFloat) -> some View {
        modifier(PaletteBorder(cornerRadius: cornerRadius))
    }

    func unselectedPostPalette(inset: CGFloat) -> some View {
        modifier(UnselectedPostPalette(inset: inset))
    }
}
