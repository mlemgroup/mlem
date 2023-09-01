//
//  Environment - Fullscreen Label Provider.swift
//  Mlem
//
//  Created by tht7 on 22/08/2023.
//

import Foundation
import SwiftUI

/// this is for views UP the stack  to provide a label for the fullscreen displayer
private struct FullScreenLabelProvider: EnvironmentKey {
    static let defaultValue: (() -> AnyView)? = nil
}

/// this is for views UP the stack to be able to provide context actions
private struct FullScreenContextMenuProvider: EnvironmentKey {
    static let defaultValue: (() -> [MenuFunction])? = nil
}

/// this is for views DOWN the stack to be able to provide context actions
private struct FullScreenContextMenuDonationCollector: EnvironmentKey {
    static let defaultValue: ([MenuFunction]) -> Void = { _ in }
}

// This is used when a view might be displayed on top of fullscreen content to allow that view to dismiss itself
// think of the annoying Hud windows, that's how they'll let themselfs out
private struct FullScreenDismissAction: EnvironmentKey {
    static let defaultValue: () -> Void = { }
}

private struct FullScreenDoubleTapHandler: EnvironmentKey {
    static let defaultValue: (() -> AnyView)? = nil
}

extension EnvironmentValues {
    var fullscreenLabel: (() -> AnyView)? {
        get { self[FullScreenLabelProvider.self] }
        set { self[FullScreenLabelProvider.self] = newValue }
    }
    
    var fullscreenContextMenu: (() -> [MenuFunction])? {
        get { self[FullScreenContextMenuProvider.self] }
        set { self[FullScreenContextMenuProvider.self] = newValue }
    }
    
    var fullscreenContextMenuDonationCollector: ([MenuFunction]) -> Void {
        get { self[FullScreenContextMenuDonationCollector.self] }
        set { self[FullScreenContextMenuDonationCollector.self] = newValue }
    }
    
    var fullscreenDismiss: () -> Void {
        get { self[FullScreenDismissAction.self] }
        set { self[FullScreenDismissAction.self] = newValue }
    }
    
    var onFullscreenDoubleTap: (() -> AnyView)? {
        get { self[FullScreenDoubleTapHandler.self] }
        set { self[FullScreenDoubleTapHandler.self] = newValue }
    }
}

extension View {
    func fullScreenLabel(
        @ViewBuilder label: @escaping () -> some View
    ) -> some View {
        environment(\.fullscreenLabel) { AnyView(label()) }
    }
    
    func onFullscreenContextMenue(
        _ menuBuilder: @escaping () -> [MenuFunction]
    ) -> some View {
        environment(\.fullscreenContextMenu, menuBuilder)
    }
    
    func onFullScreenDoubleTap(
        @ViewBuilder _ handler: @escaping () -> some View
    ) -> some View {
        environment(\.onFullscreenDoubleTap) { AnyView(handler()) }
    }
}
