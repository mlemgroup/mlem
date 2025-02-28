//
//  ApiClient+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/06/2024.
//

import Foundation
import MlemMiddleware
import PhotosUI
import SwiftUI

extension ApiClient {
    func isActive(appState: AppState) -> Bool {
        appState.guestSession.api === self || appState.activeSessions.contains(where: { $0.api === self })
    }
    
    func canInteract(appState: AppState) -> Bool { isActive(appState: appState) && token != nil }
    
    var downvotesEnabled: Bool {
        myInstance?.downvotesEnabled ?? true
    }
}
