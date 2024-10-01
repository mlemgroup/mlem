//
//  CapsuleButtonStyle.swift
//  Mlem
//
//  Created by Sjmarf on 28/09/2024.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    @Environment(Palette.self) var palette
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(palette.accent)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground, in: .capsule)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CapsuleButtonStyle {
    @MainActor static var capsule: CapsuleButtonStyle { .init() }
}
