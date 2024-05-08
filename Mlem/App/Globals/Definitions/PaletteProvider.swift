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
    
    var background: Color { get }
    var secondaryBackground: Color { get }
    var tertiaryBackground: Color { get }
}

@Observable
class PaletteProvider: PaletteProviding {
    /// Current color palette
    private var palette: any PaletteProviding = DefaultPalette()
    
    /// Updates the current color palette
    func changePalette(to newPalette: any PaletteProviding) {
        palette = newPalette
    }
    
    // ColorProviding conformance
    var background: Color { palette.background }
    var secondaryBackground: Color { palette.secondaryBackground }
    var tertiaryBackground: Color { palette.tertiaryBackground }

    var upvoteColor: Color { palette.upvoteColor }
    var downvoteColor: Color { palette.downvoteColor }
    var saveColor: Color { palette.saveColor }
}
