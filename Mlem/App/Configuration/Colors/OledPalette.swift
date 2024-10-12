//
//  OledPalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-10-07.
//

import SwiftUI

extension ColorPalette {
    static let oled: ColorPalette = {
        var palette = ColorPalette.standard
        palette.supportedModes = .dark
        palette.bordered = true
        palette.background = .black
        palette.secondaryBackground = .black
        palette.tertiaryBackground = .black
        palette.groupedBackground = .black
        palette.secondaryGroupedBackground = .black
        palette.tertiaryGroupedBackground = .black
        return palette
    }()
}
