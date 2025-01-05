//
//  Checkbox.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-05.
//

import SwiftUI

struct Checkbox: View {
    @Environment(Palette.self) private var palette
    
    let isOn: Bool
    
    var body: some View {
        VStack {
            if isOn {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(palette.selectedInteractionBarItem, .tint)
                    .imageScale(.large)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(palette.tertiary)
                    .imageScale(.large)
            }
        }
    }
}
