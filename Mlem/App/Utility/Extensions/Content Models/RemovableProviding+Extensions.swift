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
}
