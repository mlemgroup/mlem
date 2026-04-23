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

    let color: ThemedColor
    let iconWeight: Font.Weight

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 15) {
            configuration.icon
                .fontWeight(iconWeight)
                .symbolVariant(.fill)
                .foregroundStyle(.white)
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(10)
                .background(color.gradient(palette: palette), in: .circle)
            configuration.title
        }
    }
}
