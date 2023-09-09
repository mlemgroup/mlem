//
//  SortMenuButtonStyle.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023.
//

import SwiftUI

struct SortMenuButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State var isSelected: Bool
    
    var background: AnyView {
        if isSelected && isEnabled {
            return AnyView(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.8))
            )
        } else {
            return AnyView(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(background)
            .foregroundStyle((isSelected && isEnabled) ? .white : .primary)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.interactiveSpring(), value: configuration.isPressed)
            .scaleEffect(isEnabled ? 1 : 0.95)
            .opacity(isEnabled ? 1 : 0.5)
    }
}
