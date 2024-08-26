//
//  BasicAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import Dependencies
import SwiftUI

struct BasicAction: Action {
    let id: String
    let appearance: ActionAppearance
    
    let confirmationPrompt: String?

    /// If this is nil, the BasicAction is disabled
    var callback: (() -> Void)?
    
    var disabled: Bool { callback == nil }
    
    /// - Parameter id: This must be unique to the action AND contain the model's unique ID.
    /// If you don't do this, SwiftUI can get confused in a lazy view.
    init(
        id: String,
        appearance: ActionAppearance,
        confirmationPrompt: String? = nil,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.id = id
        self.appearance = appearance
        self.confirmationPrompt = confirmationPrompt
        self.callback = enabled ? callback : nil
    }
    
    func callbackWithConfirmation(navigation: NavigationLayer) {
        if let callback {
            if let confirmationPrompt {
                navigation.showPopup(ActionGroup(
                    appearance: .init(label: "Confirm", color: .gray, icon: Icons.success),
                    prompt: confirmationPrompt,
                    children: [
                        BasicAction(
                            id: "",
                            appearance: .init(label: "Yes", isOn: false, color: Palette.main.warning, icon: ""),
                            callback: callback
                        )
                    ]
                ))
            } else {
                callback()
            }
        }
    }
}
