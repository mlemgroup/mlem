//
//  SettingsInteractionBarSummaryView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import SwiftUI

struct SettingsInteractionBarSummaryView<Configuration: InteractionBarConfiguration>: View {
    @Environment(Palette.self) private var palette
    
    var title: LocalizedStringResource = "Interaction Bar"
    var configuration: Configuration
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(configuration.all, id: \.self) { item in
                HStack(spacing: 0) {
                    switch item {
                    case let .action(action):
                        Image(systemName: action.appearance.barIcon)
                            .frame(width: 24, height: 24)
                    case let .counter(counter):
                        if let appearance = counter.appearance.leading {
                            Image(systemName: appearance.barIcon)
                                .frame(width: 24, height: 24)
                        }
                        if let appearance = counter.appearance.trailing {
                            Image(systemName: appearance.barIcon)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .font(.footnote)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: 5))
            }
            .foregroundStyle(palette.secondary)
            .lineLimit(1)
        }
    }
}
