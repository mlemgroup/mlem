//
//  View+PopupAnchor.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2024.
//

import SwiftUI

struct PopupAnchor: ViewModifier {
    @State var model: PopupAnchorModel
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                model.popup?.appearance.label ?? "",
                isPresented: Binding(
                    get: { model.popup != nil },
                    set: {
                        if !$0 { model.dismissPopup() }
                    }
                )
            ) {
                ForEach(model.popup?.children ?? [], id: \.id) { action in
                    MenuButton(action: action)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(model.popup?.prompt ?? "")
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

@Observable
class PopupAnchorModel {
    private(set) var popup: ActionGroup?
    
    func showPopup(_ actionGroup: ActionGroup) {
        if popup == nil {
            popup = actionGroup
        } else {
            popup = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.popup = actionGroup
            }
        }
    }
        
    func dismissPopup() {
        popup = nil
    }
}
