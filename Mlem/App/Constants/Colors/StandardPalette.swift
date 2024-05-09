//
//  DefaultColors.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import SwiftUI

struct StandardPalette: PaletteProviding {
    let primary = Color.primary
    let background = Color(UIColor.systemBackground)
    let secondaryBackground = Color(UIColor.secondarySystemBackground)
    let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    let accent = Color.black
    let uiAccent = UIColor.systemBlue
    
    let upvote = Color.blue
    let downvote = Color.red
    let save = Color.green
}
