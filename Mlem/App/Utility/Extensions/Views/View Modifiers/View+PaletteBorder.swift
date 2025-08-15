//
//  View+PaletteBorder.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-10-10.
//

import Foundation
import SwiftUI

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

extension View {
    /// Applies a rounded rect border to the view if the current palette `.bordered` is `true`
    func paletteBorder(cornerRadius: CGFloat) -> some View {
        modifier(PaletteBorder(cornerRadius: cornerRadius))
    }
}
