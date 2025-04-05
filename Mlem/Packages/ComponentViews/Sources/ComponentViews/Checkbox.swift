//
//  Checkbox.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-05.
//

import SwiftUI
import Theming

public struct Checkbox: View {
    public let isOn: Bool
    
    public init(isOn: Bool) {
        self.isOn = isOn
    }
    
    public var body: some View {
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
