//
//  View+PopupAnchor.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2024.
//

import Icons
import SwiftUI

struct PopupAnchor: ViewModifier {
    @State var model: PopupAnchorModel
    
    var actions: [PopupAnchorModel.Action] {
        model.data?.actions ?? []
    }
    
    var isPresented: Binding<Bool> {
        Binding(
            get: { model.data != nil },
            set: {
                if !$0 { model.dismissPopup() }
            }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .alert(
                model.data?.message ?? "",
                isPresented: isPresented
            ) {
                buttonsView
            }
            .environment(model)
    }
    
    @ViewBuilder
    var buttonsView: some View {
        ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
            Button(
                action.title,
                role: action.isDestructive ? .destructive : nil
            ) {
                action.callback()
                model.outcome = .confirmed
            }
        }
        Button("Cancel", role: .cancel) {
            model.outcome = .cancelled
        }
    }
}

extension View {
    @ViewBuilder
    func popupAnchor(model: PopupAnchorModel = .init()) -> some View {
        modifier(PopupAnchor(model: model))
    }
}
