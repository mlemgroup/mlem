//
//  PopupAnchorModel.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-14.
//

import Foundation

@Observable
class PopupAnchorModel {
    struct PopupData {
        var message: String
        var actions: [Action]?
    }

    enum Outcome {
        case cancelled, confirmed
    }
    
    struct Action {
        let title: String
        let isDestructive: Bool
        let callback: @MainActor () -> Void
        
        init(title: LocalizedStringResource, isDestructive: Bool, callback: @escaping () -> Void) {
            self.title = .init(localized: title)
            self.isDestructive = isDestructive
            self.callback = callback
        }
        
        @_disfavoredOverload
        init(title: String, isDestructive: Bool, callback: @escaping () -> Void) {
            self.title = title
            self.isDestructive = isDestructive
            self.callback = callback
        }
    }
    
    private(set) var data: PopupData?
    var outcome: Outcome?
    
    func showPopup(message: LocalizedStringResource, _ actions: [Action]?) {
        showPopup(message: .init(localized: message), actions)
    }
    
    @_disfavoredOverload
    func showPopup(message: String, _ actions: [Action]?) {
        let newData = PopupData(message: message, actions: actions)
        if data == nil {
            data = newData
        } else {
            data = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.data = newData
            }
        }
    }
        
    func dismissPopup() {
        data = nil
    }
}

extension PopupAnchorModel {
    func showPopup(_ actionGroup: ActionGroup) {
        let children: [PopupAnchorModel.Action] = actionGroup.children.map { child in
            .init(title: child.appearance.label, isDestructive: child.appearance.isDestructive) { @MainActor in
                if let child = child as? BasicAction {
                    child.callbackWithConfirmation(popupModel: self)
                } else {
                    assertionFailure("Not implemented")
                }
            }
        }
        showPopup(
            message: actionGroup.prompt ?? actionGroup.appearance.label,
            children
        )
    }
}
