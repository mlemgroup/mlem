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
        var title: String
        var message: String?
        var actions: [Action]?
    }
    
    struct Action {
        let title: String
        let isDestructive: Bool
        let callback: @MainActor () -> Void
    }
    
    private(set) var data: PopupData?
    
    func showPopup(title: String, message: String?, _ actions: [Action]?) {
        let newData = PopupData(title: title, message: message, actions: actions)
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
            title: actionGroup.appearance.label,
            message: actionGroup.prompt,
            children
        )
    }
}
