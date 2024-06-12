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
    @Environment(NavigationLayer.self) var navigation
    
    let entity: any ContentStub
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
                if !isLoading, !entity.api.isActive {
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
                    + Text(entity.api.host ?? "page").fontWeight(.semibold)
                    + Text(" as guest")
            )
            .foregroundStyle(palette.primary.opacity(0.5))
            Spacer()
            Button("More Info", systemImage: "questionmark.circle") {
                navigation.openSheet(.externalApiInfo(
                    api: entity.api,
                    actorId: entity.actorId
                ))
            }
            .labelStyle(.iconOnly)
        }
    }
}

extension View {
    func externalApiWarning(entity: any ContentStub, isLoading: Bool) -> some View {
        modifier(ExternalApiWarningModifier(entity: entity, isLoading: isLoading))
    }
}
