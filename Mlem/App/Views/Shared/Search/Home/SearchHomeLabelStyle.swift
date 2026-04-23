//
//  SearchHomeLabelStyle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import SwiftUI
import Theming

struct SearchHomeLabelStyle: LabelStyle {
    @Environment(\.palette) var palette
    @Environment(\.tint) var tint

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 15) {
            configuration.icon
                .symbolVariant(.fill.circle)
                .foregroundStyle(.white, tint.gradient(palette: palette))
                .scaledToFit()
                .font(.system(size: 35))
                .frame(width: 35, height: 35)
            configuration.title
        }
    }
}
