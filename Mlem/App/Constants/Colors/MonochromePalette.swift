//
//  MonochromePalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import Foundation
import SwiftUI

struct MonochromePalette: PaletteProviding {
    let background = Color(UIColor.systemBackground)
    let secondaryBackground = Color(UIColor.secondarySystemBackground)
    let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    let accent = Color.black
    let uiAccent = UIColor.black
    
    let upvoteColor = Color.black
    let downvoteColor = Color.black
    let saveColor = Color.black
}
