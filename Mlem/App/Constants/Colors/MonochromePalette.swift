//
//  MonochromePalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import Foundation
import SwiftUI

struct MonochromePalette: PaletteProviding {
    let primary = Color.primary
    let background = Color(UIColor.systemBackground)
    let secondaryBackground = Color(UIColor.secondarySystemBackground)
    let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    let accent = Color.black
    let uiAccent = UIColor.black
    
    let upvote = Color.black
    let downvote = Color.black
    let save = Color.black
}
