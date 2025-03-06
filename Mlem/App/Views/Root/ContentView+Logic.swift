//
//  ContentView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import Nuke
import SwiftUI

extension ContentView {
    var shouldDisplayToasts: Bool {
        navigationModel.layers.allSatisfy { !$0.canDisplayToasts }
    }
    
    var avatarRefreshHash: Int {
        var hasher = Hasher()
        hasher.combine(appState.firstAccount.avatar)
        hasher.combine(tabProfileShowAvatar)
        hasher.combine(colorScheme)
        return hasher.finalize()
    }
    
    func loadAvatar(url: URL) async {
        do {
            if tabProfileShowAvatar {
                let imageTask = ImagePipeline.shared.imageTask(with: url.withIconSize(128))
                let avatarImage = try await imageTask.image
                    .resized(to: .init(width: imageTask.image.size.width / imageTask.image.size.height * 26, height: 26))
                    .circleMasked
                    .withRenderingMode(.alwaysOriginal)
                
                let selectedAvatarImage = try await imageTask.image
                    .resized(to: .init(width: imageTask.image.size.width / imageTask.image.size.height * 26, height: 26))
                    .circleBorder(color: .init(palette.accent), width: 3.5)
                    .withRenderingMode(.alwaysOriginal)
                
                Task { @MainActor in
                    self.avatarImage = avatarImage
                    self.selectedAvatarImage = selectedAvatarImage
                }
            }
        } catch {
            handleError(error, silent: true)
        }
    }
}
