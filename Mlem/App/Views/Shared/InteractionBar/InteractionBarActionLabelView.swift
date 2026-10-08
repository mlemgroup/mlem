//
//  InteractionBarActionView.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import Actions
import Icons
import SwiftUI
import Theming

struct InteractionBarActionLabelView: View {
    static let unweightedSymbols: Set<Icon> = [.lemmy.upvoted, .lemmy.downvoted]

    @Setting(\.a11y_showInteractionBarButtonBackground) var showInteractionBarButtonBackground
        
    let appearance: ActionAppearance
    
    init( _ appearance: ActionAppearance) {
        self.appearance = appearance
    }
    
    var body: some View {
        let label = appearance.label(describing: .currentState)
        Image(icon: label.icon)
            .resizable()
            .fontWeight(Self.unweightedSymbols.contains(label.icon) ? .regular : .medium)
            .symbolVariant(appearance.prominent ? .fill : .none)
            // .opacity(appearance.isInProgress ? 0 : 1)
            .scaledToFit()
            .frame(width: Constants.main.barIconSize, height: Constants.main.barIconSize)
            .frame(width: Constants.main.barIconBackgroundSize, height: Constants.main.barIconBackgroundSize)
            .foregroundStyle(appearance.prominent ? .themedContrastingLabel : .themedPrimary)
            .background(appearance.prominent ? label.color : .clear, in: .rect(cornerRadius: Constants.main.barIconCornerRadius))
            .background {
                if showOutline {
                    RoundedRectangle(cornerRadius: Constants.main.barIconCornerRadius)
                        .fill(.themedTertiaryGroupedBackground)
                        .paletteBorder(cornerRadius: Constants.main.barIconCornerRadius)
                }
            }
            .frame(width: Constants.main.barIconHitbox, height: Constants.main.barIconHitbox)
            .contentShape(Rectangle())
            // .opacity(appearance.isInProgress ? 0.5 : 1)
            // .overlay {
            //     if appearance.isInProgress {
            //         ProgressView()
            //             .tint(appearance.isOn ? .themedContrastingLabel : .themedPrimary)
            //     }
            // }
            .transaction { $0.animation = nil }
    }

    var showOutline: Bool {
        !appearance.prominent && showInteractionBarButtonBackground
    }
}
