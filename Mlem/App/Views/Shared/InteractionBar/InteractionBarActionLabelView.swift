//
//  InteractionBarActionView.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import SwiftUI

struct InteractionBarActionLabelView: View {
    static let unweightedSymbols: Set<String> = [Icons.upvote, Icons.downvote]
    
    @Environment(Palette.self) private var palette
    
    let appearance: ActionAppearance
    @State var isInProgress: Bool
    
    init(_ appearance: ActionAppearance, isInProgress: Bool = false) {
        self.appearance = appearance
        self._isInProgress = .init(wrappedValue: isInProgress)
    }
    
    var body: some View {
        Image(systemName: appearance.barIcon)
            .resizable()
            .fontWeight(Self.unweightedSymbols.contains(appearance.barIcon) ? .regular : .medium)
            .symbolVariant(isOn ? .fill : .none)
            .opacity(isInProgress ? 0 : 1)
            .scaledToFit()
            .frame(width: Constants.main.barIconSize, height: Constants.main.barIconSize)
            .padding(Constants.main.barIconPadding)
            .foregroundColor(isOn ? palette.selectedInteractionBarItem : palette.primary)
            .background(isOn ? appearance.color : .clear, in: .rect(cornerRadius: Constants.main.barIconCornerRadius))
            .contentShape(Rectangle())
            .opacity(isInProgress ? 0.5 : 1)
            .overlay {
                if isInProgress {
                    ProgressView()
                        .tint(palette.selectedInteractionBarItem)
                }
            }
    }
    
    var isOn: Bool {
        appearance.isOn || isInProgress
    }
}
