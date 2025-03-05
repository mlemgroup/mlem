//
//  BasicAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import Dependencies
import MlemMiddleware
import SwiftUI

struct BasicAction: Action {
    let id: String
    let appearance: ActionAppearance
    
    let confirmationPrompt: String?

    /// If this is nil, the BasicAction is disabled
    var callback: (@MainActor () -> Void)?
    
    var disabled: Bool { callback == nil }
    
    /// - Parameter id: This must be unique to the action AND contain the model's unique ID.
    /// If you don't do this, SwiftUI can get confused in a lazy view.
    init(
        id: String,
        appearance: ActionAppearance,
        confirmationPrompt: LocalizedStringResource? = nil,
        enabled: Bool = true,
        callback: (@MainActor () -> Void)? = nil
    ) {
        self.id = id
        self.appearance = appearance
        if let confirmationPrompt {
            self.confirmationPrompt = .init(localized: confirmationPrompt)
        } else {
            self.confirmationPrompt = nil
        }
        self.callback = enabled ? callback : nil
    }
    
    @MainActor
    func callbackWithConfirmation(popupModel: PopupAnchorModel) {
        if let callback {
            if let confirmationPrompt {
                popupModel.showPopup(ActionGroup(
                    appearance: .init(label: "Confirm", color: .gray, icon: Icons.success),
                    prompt: confirmationPrompt,
                    children: {
                        BasicAction(
                            id: "",
                            appearance: .init(label: "Yes", isOn: false, color: Palette.main.warning, icon: ""),
                            callback: callback
                        )
                    }
                ))
            } else {
                callback()
            }
        }
    }
    
    func disabled(_ value: Bool) -> BasicAction {
        var new = self
        if value {
            new.callback = nil
        }
        return new
    }
}
