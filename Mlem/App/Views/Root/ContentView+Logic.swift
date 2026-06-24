//
//  ContentView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import Haptics
import MlemMiddleware
import Nuke
import SafariServices
import SwiftUI

extension ContentView {
    func handleIncomingDeeplink(url: URL) {
        guard url.scheme == "mlem" else { return }
        if url.absoluteString.hasPrefix("mlem://fediverse-auth/handoff") {
            handleHandoffDeeplink(url: url)
        } else {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            guard let targetURL = components?.url else { return }
            navigationModel.pendingOpenURL = targetURL
        }
    }

    private func handleHandoffDeeplink(url: URL) {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return }
        let session = queryItems.first { $0.name == "session" }?.value
        let handle = queryItems.first { $0.name == "actor" }?.value
        guard let session, let handle, let personHandle = try? PersonHandle(string: handle) else { return }

        guard let defaultAccount = (appState.firstAccount as? UserAccount) ?? AccountsTracker.main.userAccounts.first else {
            return
        }

        // This logic is needed to present the sheet over the top of the SFSafariViewController.
        let topVC = UIApplication.shared.firstKeyWindow?.rootViewController?.topMostViewController()
        if topVC is SFSafariViewController {
            let view = AuthHandoffView(
                session: session,
                personHandle: personHandle,
                openedFromInAppBrowser: true,
                defaultAccount: defaultAccount
            )
            .environment(appState)
            .environment(mediaTracker)
            .environment(hapticManager)
            let hostingController = UIHostingController(rootView: view)
            hostingController.sheetPresentationController?.detents = [.medium()]
            topVC?.present(hostingController, animated: true)
        } else {
            navigationModel.openSheet(.authHandoff(
                session: session,
                personHandle: personHandle,
                defaultAccount: defaultAccount
            ))
        }
    }

    var shouldDisplayToasts: Bool {
        navigationModel.layers.allSatisfy { !$0.canDisplayToasts }
    }
    
    var avatarRefreshHash: Int {
        var hasher = Hasher()
        hasher.combine(appState.firstAccount.avatar)
        hasher.combine(tabProfileShowAvatar)
        hasher.combine(colorPalette)
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
                    .circleBorder(color: .init(colorPalette.palette.accent), width: 3.5)
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
    
    func handleHapticError(_ error: HapticError) {
        handleError(error, silent: !developerMode)
    }
}
