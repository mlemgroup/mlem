//
//  SelectableContentProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import MlemMiddleware

extension SelectableContentProviding {
    func showTextSelectionSheet() {
        NavigationModel.main.openSheet(.selectText(selectableContent ?? ""))
    }
    
    func selectTextAction() -> BasicAction {
        .init(
            id: "selectText\(actorId.absoluteString)",
            isOn: false,
            label: "Select Text",
            color: Palette.main.accent,
            icon: Icons.select,
            menuIcon: Icons.select,
            callback: selectableContent == nil ? nil : showTextSelectionSheet
        )
    }
}
