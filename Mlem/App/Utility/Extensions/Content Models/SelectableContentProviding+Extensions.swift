//
//  SelectableContentProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import MlemMiddleware

extension SelectableContentProviding {
    @MainActor
    func showTextSelectionSheet() {
        NavigationModel.main.openSheet(.selectText(selectableContent ?? ""))
    }
    
    func selectTextAction() -> BasicAction {
        .init(
            id: "selectText\(actorId.description)",
            appearance: .selectText(),
            callback: selectableContent == nil ? nil : showTextSelectionSheet
        )
    }
}
