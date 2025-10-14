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
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                model.data?.title ?? "",
                isPresented: Binding(
                    get: { model.data != nil },
                    set: {
                        if !$0 { model.dismissPopup() }
                    }
                )
            ) {
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    Button(
                        action.title,
                        role: action.isDestructive ? .destructive : nil,
                        action: action.callback
                    )
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(model.data?.message ?? "")
            }
            .environment(model)
    }
}

extension View {
    @ViewBuilder
    func popupAnchor(model: PopupAnchorModel = .init()) -> some View {
        modifier(PopupAnchor(model: model))
    }
}
