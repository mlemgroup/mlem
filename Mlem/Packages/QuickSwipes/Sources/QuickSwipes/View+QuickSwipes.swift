//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import MlemMiddleware
import SwiftUI
import Theming

public extension View {
    /// Adds quick swipes to a view.
    ///
    /// NOTE: if the view you are attaching this to also has a context menu, add the context menu view modifier AFTER the quick swipes modifier! This will prevent the quick swipe from triggering and appearing bugged on an aborted context menu pop if the context menu animation initiates.
    /// - Parameters:
    ///   - leading: leading edge quick swipes, ordered by ascending swipe distance from leading edge
    ///   - trailing: trailing edge quick swipes, ordered by ascending swipe distance from leading edge
    @ViewBuilder
    func quickSwipes(
        leading: [QuickSwipeAction] = [],
        trailing: [QuickSwipeAction] = []
    ) -> some View {
        modifier(
            QuickSwipeViewModifier(
                config: .init(
                    leadingActions: leading,
                    trailingActions: trailing
                )
            )
        )
    }
    
    @ViewBuilder
    func quickSwipes(_ config: SwipeConfiguration) -> some View {
        modifier(QuickSwipeViewModifier(config: config))
    }
}
