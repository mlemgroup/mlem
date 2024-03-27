//
//  View+DestructiveConfirmation.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-06.
//

import Foundation
import SwiftUI

struct MenuFunctionPopupView: ViewModifier {
    @Binding var menuFunctionPopup: MenuFunctionPopup?
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "Destructive Action Confirmation",
                isPresented: Binding(get: { menuFunctionPopup != nil }, set: { _, _ in menuFunctionPopup = nil })
            ) {
                if let actions = menuFunctionPopup?.actions {
                    ForEach(actions, id: \.text) { action in
                        Button(action.text, role: action.isDestructive ? .destructive : nil, action: action.callback)
                    }
                }
            } message: {
                if let prompt = menuFunctionPopup?.prompt {
                    Text(prompt)
                }
            }
    }
}

extension View {
    /// View modifier to attach a destructive action confirmation.
    ///
    /// To use, add the following to the view in which you use it:
    ///
    /// \@State private var isPresentingConfirmDestructive: Bool = false
    /// \@State private var confirmationMenuFunction: StandardMenuFunction?
    ///
    /// func confirmDestructive(destructiveFunction: StandardMenuFunction) {
    ///     confirmationMenuFunction = destructiveFunction
    ///     isPresentingConfirmDestructive = true
    /// }
    ///
    /// Calling confirmDestructive with a StandardMenuFunction will then trigger a confirmation.
    ///
    /// - Parameters:
    ///   - isPresentingConfirmDestructive: binding Bool to toggle the confirmation presentation
    ///   - confirmationMenuFunction: menu function to confirm
    func destructiveConfirmation(
        menuFunctionPopup: Binding<MenuFunctionPopup?>
    ) -> some View {
        modifier(MenuFunctionPopupView(
            menuFunctionPopup: menuFunctionPopup
        ))
    }
}
