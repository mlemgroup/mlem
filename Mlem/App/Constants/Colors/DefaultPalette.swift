//
//  DefaultColors.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import SwiftUI

struct DefaultPalette: PaletteProviding {
    let background = Color(UIColor.systemBackground)
    let secondaryBackground = Color(UIColor.secondarySystemBackground)
    let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    let accent = Color.black
    let uiAccent = UIColor.systemBlue
    
    let upvoteColor = Color.blue
    let downvoteColor = Color.red
    let saveColor = Color.green
}
