//
//  EnvironmentValues+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 19/09/2024.
//

import Haptics
import MlemMiddleware
import SwiftUI

extension EnvironmentValues {
    @Entry var postContext: Post?
    @Entry var commentContext: (any Comment1Providing)?
    @Entry var communityContext: (any Community1Providing)?
    @Entry var reportContext: Report?
    @Entry var feedContext: FeedContext?
    
    @Entry var parentFrameWidth: CGFloat = .zero
    @Entry var isRootView: Bool = false
    
    @Entry var scrollProxy: ScrollViewProxy?
    @Entry var exposeRemovedContent: Bool = false
    
    var appState: AppState {
        if let appState = self[AppState.self] {
            return appState
        } else {
            assertionFailure()
            return .main
        }
    }

    var hapticManager: HapticManager {
        if let hapticManager = self[HapticManager.self] {
            return hapticManager
        } else {
            assertionFailure()
            return .main
        }
    }

    var popupModel: PopupAnchorModel? { self[PopupAnchorModel.self] }
    var toastModel: ToastModel? { self[ToastModel.self] }
    var navigation: NavigationLayer? { self[NavigationLayer.self] }
    var commentTreeTracker: CommentTreeTracker? { self[CommentTreeTracker.self] }
}

struct RootLayer {
    let layer: NavigationLayer
}
