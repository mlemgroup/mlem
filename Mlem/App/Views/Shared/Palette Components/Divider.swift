//
//  Divider.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI

/// Divider() that colors itself appropriately to the palette.
/// DO NOT use in UIKit environments!
struct Divider: View {
    @Environment(Palette.self) var palette
    
    var body: some View {
        SwiftUI.Divider()
            .hidden()
            .overlay(Color(light: palette.secondary.opacity(0.5), dark: palette.neutralAccent.opacity(0.35)))
    }
}
