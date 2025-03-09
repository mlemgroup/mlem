//
//  Palette+Oled.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-08.
//

import Foundation
import Theming

extension Palette {
    static let oled: Self = {
        var palette: Self = .default
        palette.bordered = true
        palette.background.primary = .black
        palette.background.secondary = .black
        palette.background.tertiary = .black
        palette.groupedBackground.primary = .black
        palette.groupedBackground.secondary = .black
        palette.groupedBackground.tertiary = .black
        return palette
    }()
}
