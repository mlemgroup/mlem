//
//  ColorProvider.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import Foundation
import SwiftUI

protocol PaletteProviding {
    // interactions
    var upvoteColor: Color { get }
    var downvoteColor: Color { get }
    var saveColor: Color { get }
    
    var uiAccent: UIColor { get }
}

extension PaletteProviding {
    var systemBackground: Color { Color(UIColor.systemBackground) }
    var secondarySystemBackground: Color { Color(UIColor.secondarySystemBackground) }
    var tertiarySystemBackground: Color { Color(UIColor.tertiarySystemBackground) }
}

@Observable
class PaletteProvider: PaletteProviding {
    /// Current color palette
    private var palette: any PaletteProviding = DefaultPalette()
    
    /// Static ColorProvider to make it available in contexts were @Environment is unavailable
    static var main: PaletteProvider = .init()
    
    /// Updates the current color palette
    func changePalette(to newPalette: any PaletteProviding) {
        palette = newPalette
    }
    
    // ColorProviding conformance
    var systemBackground: Color { palette.systemBackground }
    var secondarySystemBackground: Color { palette.secondarySystemBackground }
    var tertiarySystemBackground: Color { palette.tertiarySystemBackground }
    var uiAccent: UIColor { palette.uiAccent }

    var upvoteColor: Color { palette.upvoteColor }
    var downvoteColor: Color { palette.downvoteColor }
    var saveColor: Color { palette.saveColor }
}
