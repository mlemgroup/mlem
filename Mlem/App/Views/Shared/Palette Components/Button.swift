//
//  Button.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-06.
//

import Foundation
import SwiftUI

struct PaletteButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if isEnabled {
                configuration.label
                    .foregroundStyle(.tint)
            } else {
                configuration.label
                    .foregroundStyle(.themedSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
