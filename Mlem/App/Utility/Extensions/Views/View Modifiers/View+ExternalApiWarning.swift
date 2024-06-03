//
//  View+ExternalApiWarning.swift
//  Mlem
//
//  Created by Sjmarf on 02/06/2024.
//

import MlemMiddleware
import SwiftUI

private struct ExternalApiWarningModifier: ViewModifier {
    @Environment(Palette.self) var palette
    
    let entity: any ContentStub

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
                if !entity.api.isActive {
                    label
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        // Using colors directly here causes the background to extend
                        // into the navbar, so use filled rectangles instead
                        .background {
                            Rectangle()
                                .fill(palette.accent.opacity(0.2))
                        }
                        .background {
                            Rectangle()
                                .fill(.thickMaterial)
                        }
                        .padding(.bottom, 3)
                }
            }
    }
    
    var label: some View {
        HStack {
            (
                Text("Viewing ")
                    + Text(entity.host ?? "page").fontWeight(.semibold)
                    + Text(" as guest")
            )
            .foregroundStyle(palette.primary.opacity(0.5))
            Spacer()
            Button("More Info", systemImage: "questionmark.circle") {}
            
                .labelStyle(.iconOnly)
        }
    }
}

extension View {
    func externalApiWarning(entity: any ContentStub) -> some View {
        modifier(ExternalApiWarningModifier(entity: entity))
    }
}
