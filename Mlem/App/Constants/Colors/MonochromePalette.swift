//
//  MonochromePalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import Foundation
import SwiftUI

struct MonochromePalette: PaletteProviding {
    let upvoteColor = Color.black
    let downvoteColor = Color.black
    let saveColor = Color.black
    
    var background: Color { Color(UIColor.systemBackground) }
    var secondaryBackground: Color { Color(UIColor.secondarySystemBackground) }
    var tertiaryBackground: Color { Color(UIColor.tertiarySystemBackground) }
}
