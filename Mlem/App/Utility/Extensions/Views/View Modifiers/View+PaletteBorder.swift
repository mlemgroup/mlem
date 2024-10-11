//
//  View+PaletteBorder.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-10-10.
//

import SwiftUICore

import Foundation
import SwiftUI

private struct PaletteBorder: ViewModifier {
    @Environment(Palette.self) var palette
    
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if palette.bordered {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(palette.divider, lineWidth: 0.5)
                }
            }
    }
}

extension View {
    /// Blurs an image relative to its size
    func paletteBorder(cornerRadius: CGFloat) -> some View {
        modifier(PaletteBorder(cornerRadius: cornerRadius))
    }
}
