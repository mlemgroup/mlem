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
            appearance: .init(
                label: "Select Text",
                isOn: false,
                color: Palette.main.accent,
                icon: Icons.select
            ),
            callback: selectableContent == nil ? nil : showTextSelectionSheet
        )
    }
}
