//
//  CollapsibleSheetView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import SwiftUI

struct CollapsibleSheetView<Content: View>: View {
    @Environment(Palette.self) var palette
    
    let content: Content
    let canDismiss: Bool
    
    @Binding var presentationSelection: PresentationDetent
    
    init(
        presentationSelection: Binding<PresentationDetent>,
        canDismiss: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.canDismiss = canDismiss
        self._presentationSelection = presentationSelection
        self.content = content()
    }

    var body: some View {
        content
            .opacity(presentationSelection == .large ? 1 : 0)
            .overlay(alignment: .top) {
                Button {
                    presentationSelection = .large
                } label: {
                    Image(systemName: "chevron.compact.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                        .foregroundStyle(palette.secondary)
                        .frame(maxWidth: .infinity, maxHeight: 62)
                        .contentShape(.rect)
                }
                .opacity(presentationSelection == .large ? 0 : 1)
            }
            .animation(.easeOut(duration: 0.2), value: presentationSelection)
            .presentationDetents(canDismiss ? [.large] : [.height(62), .large], selection: $presentationSelection)
            .interactiveDismissDisabled(!canDismiss)
            .presentationCornerRadius(presentationSelection == .large ? nil : 16)
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(.hidden)
    }
}
