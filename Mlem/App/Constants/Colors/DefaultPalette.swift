//
//  DefaultColors.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import SwiftUI

struct DefaultPalette: PaletteProviding {
    let upvoteColor = Color.blue
    let downvoteColor = Color.red
    let saveColor = Color.green
    
    var background: Color { Color(UIColor.systemBackground) }
    var secondaryBackground: Color { Color(UIColor.secondarySystemBackground) }
    var tertiaryBackground: Color { Color(UIColor.tertiarySystemBackground) }
}
