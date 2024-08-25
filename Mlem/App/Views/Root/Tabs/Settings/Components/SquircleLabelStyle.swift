//
//  SquircleLabelStyle.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct SquircleLabelStyle: LabelStyle {
    @Environment(Palette.self) private var palette
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 16) {
            configuration.icon
                .font(.body)
                .foregroundColor(palette.selectedInteractionBarItem)
                .frame(width: Constants.main.settingsIconSize, height: Constants.main.settingsIconSize)
                .background(.tint)
                .clipShape(.rect(cornerRadius: Constants.main.smallItemCornerRadius))
                .accessibilityHidden(true)
            configuration.title
        }
    }
}

extension LabelStyle where Self == SquircleLabelStyle {
    static var squircle: SquircleLabelStyle { .init() }
}
