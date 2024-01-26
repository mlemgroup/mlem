//
//  View+DestructiveConfirmation.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-06.
//

import Foundation
import SwiftUI

struct DestructiveConfirmation: ViewModifier {
    let confirmationMenuFunction: StandardMenuFunction?
    @Binding var isPresentingConfirmDestructive: Bool
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog("Destructive Action Confirmation", isPresented: $isPresentingConfirmDestructive) {
                if let destructiveCallback = confirmationMenuFunction?.callback {
                    Button("Yes", role: .destructive) {
                        Task {
                            destructiveCallback()
                        }
                    }
                }
            } message: {
                if case let .destructive(prompt: prompt) = confirmationMenuFunction?.role, let prompt {
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
        isPresentingConfirmDestructive: Binding<Bool>,
        confirmationMenuFunction: StandardMenuFunction?
    ) -> some View {
        modifier(DestructiveConfirmation(
            confirmationMenuFunction: confirmationMenuFunction,
            isPresentingConfirmDestructive: isPresentingConfirmDestructive
        ))
    }
}
