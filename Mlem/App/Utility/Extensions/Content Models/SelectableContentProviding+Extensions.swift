//
//  SelectableContentProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import MlemMiddleware

extension SelectableContentProviding {
    @MainActor
    func showTextSelectionSheet(onSelectTextCallback: (() -> Void)? = nil) {
        onSelectTextCallback?()
        NavigationModel.main.openSheet(.selectText(selectableContent ?? ""))
    }
    
    func selectTextAction(onSelectTextCallback: (() -> Void)? = nil) -> BasicAction {
        let callback: @MainActor () -> Void = { showTextSelectionSheet(onSelectTextCallback: onSelectTextCallback) }
        
        return .init(
            id: "selectText\(actorId.description)",
            appearance: .selectText(),
            callback: selectableContent == nil ? nil : callback
        )
    }
}
