//
//  SettingsInteractionBarSummaryView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import Actions
import SwiftUI

struct SettingsInteractionBarSummaryView<Configuration: InteractionBarConfiguration>: View {
    var title: LocalizedStringResource = "Interaction Bar"
    var configuration: Configuration
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(configuration.interactionBar.all, id: \.self) { item in
                HStack(spacing: 0) {
                    switch item {
                    case let .action(action):
                        Image(icon: action.appearance.label(describing: .currentState).icon)
                            .frame(width: 24, height: 24)
                    case let .counter(counter):
                        if let appearance = counter.appearance.leading {
                            actionLabel(appearance)
                        }
                        if let appearance = counter.appearance.trailing {
                            actionLabel(appearance)
                        }
                    }
                }
                .font(.footnote)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: 5))
            }
            .foregroundStyle(.themedSecondary)
            .lineLimit(1)
        }
    }

    @ViewBuilder
    func actionLabel(_ appearance: ActionAppearance) -> some View {
        let label = appearance.label(describing: .currentState)
        Image(icon: label.icon)
            .frame(width: 24, height: 24)
    }
}
