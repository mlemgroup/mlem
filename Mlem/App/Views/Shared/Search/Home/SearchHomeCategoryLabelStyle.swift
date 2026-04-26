//
//  SearchHomeCategoryLabelStyle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-24.
//

import SwiftUI
import Theming

struct SearchHomeCategoryLabelStyle: LabelStyle {
    @Environment(\.palette) var palette
    @Environment(\.tint) var tint

    static let iconSize: CGFloat = 80

    private static var innerIconSize: CGFloat {
        iconSize - 40
    }

    func makeBody(configuration: Configuration) -> some View {
            VStack {
                configuration.icon
                    .font(.system(size: Self.innerIconSize))
                    .frame(width: Self.innerIconSize, height: Self.innerIconSize)
                    .foregroundStyle(.white)
                    .symbolVariant(.fill)
                    .padding(20)
                    .background(tint.gradient(palette: palette), in: .circle)
                configuration.title
                    .fontWeight(.semibold)
                    .font(.subheadline)
            }
    }
}
