//
//  InteractionBarActionView.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import SwiftUI
import Theming

struct InteractionBarActionLabelView: View {
    static let unweightedSymbols: Set<String> = [Icons.upvote, Icons.downvote]
        
    let appearance: ActionAppearance
    
    init(_ appearance: ActionAppearance) {
        self.appearance = appearance
    }
    
    var body: some View {
        Image(systemName: appearance.barIcon)
            .resizable()
            .fontWeight(Self.unweightedSymbols.contains(appearance.barIcon) ? .regular : .medium)
            .symbolVariant(appearance.isOn ? .fill : .none)
            .opacity(appearance.isInProgress ? 0 : 1)
            .scaledToFit()
            .frame(width: Constants.main.barIconSize, height: Constants.main.barIconSize)
            .padding(Constants.main.barIconPadding)
            .foregroundStyle(appearance.isOn ? .themedContrastingLabel : .themedPrimary)
            .background(appearance.isOn ? appearance.color : .clear, in: .rect(cornerRadius: Constants.main.barIconCornerRadius))
            .contentShape(Rectangle())
            .opacity(appearance.isInProgress ? 0.5 : 1)
            .overlay {
                if appearance.isInProgress {
                    ProgressView()
                        .tint(appearance.isOn ? .themedContrastingLabel : .themedPrimary)
                }
            }
            .transaction { $0.animation = nil }
    }
}
