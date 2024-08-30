//
//  ColoredDivider.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI

/// Divider() that colors itself appropriately to the palette.
/// DO NOT use in UIKit environments!
struct PaletteDivider: View {
    @Environment(Palette.self) var palette
    
    var body: some View {
        Divider()
            .overlay(palette.neutralAccent)
    }
}
