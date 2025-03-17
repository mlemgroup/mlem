//
//  Checkbox.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-05.
//

import SwiftUI

struct Checkbox: View {
    let isOn: Bool
    
    var body: some View {
        VStack {
            if isOn {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.themedContrastingLabel, .tint)
                    .imageScale(.large)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.themedTertiary)
                    .imageScale(.large)
            }
        }
    }
}
