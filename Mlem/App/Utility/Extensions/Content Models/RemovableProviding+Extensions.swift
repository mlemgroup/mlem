//
//  RemovableProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-15.
//

import MlemMiddleware

extension RemovableProviding {
    @MainActor
    func showRemoveSheet() {
        NavigationModel.main.openSheet(.remove(self))
    }
    
    func removeAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "remove\(uid)",
            appearance: .remove(isOn: removed, isInProgress: !removedManager.isInSync),
            callback: api.canInteract(appState: appState) ? showRemoveSheet : nil
        )
    }
}
