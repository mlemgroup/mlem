//
//  View - ExpandableView.swift
//  Mlem
//
//  Created by tht7 on 18/08/2023.
//

import Foundation
import SwiftUI

protocol FullScreenActualContent {
    var fullscreenContent: URL? { get }
}

/*** tht7 note:
 * Nope can't user ViewModifier here since it works with a wierd PROXY of the view instead of the real view and SwiftUI is broken behind the sense soooooo
 * Anyway that's a cute alt ;)
 */
struct ExpandableView<Content: View>: View {
    @State public var isFullScreen: Bool = false

    let content: Content

    let dismissCallback: (() -> Void)?

    init(
        isFullScreen: Bool = false,
        dismissCallback: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        self.dismissCallback = dismissCallback
        self._isFullScreen = .init(initialValue: isFullScreen)
    }

    init(
        isFullScreen: Bool = false,
        dismissCallback: (() -> Void)? = nil,
        content: Content
    ) {
        self.content = content
        self.dismissCallback = dismissCallback
        self._isFullScreen = .init(initialValue: isFullScreen)
    }

    @ViewBuilder
    var body: some View {
        content
            .onTapGesture {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    isFullScreen = true
                }
            }.fullScreenCover(isPresented: $isFullScreen, onDismiss: dismissCallback) { [isFullScreen] in
                FullScreenViewer(
                    isOpen: $isFullScreen
                ) {
                    content
                }
            }
    }
}

extension View {
    @ViewBuilder
    func fullscreenExpandable(
        isFullScreen: Bool = false,
        dismissCallback: (() -> Void)? = nil
    ) -> ExpandableView<Self> {
            ExpandableView(
                isFullScreen: isFullScreen,
                dismissCallback: dismissCallback,
                content: self
            )
    }
}
