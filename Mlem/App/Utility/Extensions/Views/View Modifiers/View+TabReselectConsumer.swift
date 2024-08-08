//
//  View+TabReselectionConsumer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-11.
//

import Foundation
import SwiftUI

struct TabReselectionConsumer: ViewModifier {
    @Environment(TabReselectTracker.self) var tabReselectTracker

    /// Reselect actions should only trigger when the view is shown, so we track it with this
    @State var displayed: Bool = false
    
    var action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: tabReselectTracker.flag) {
                // Only execute the action if:
                // - This view is currently displayed (this prevents it from triggering while in a different tab)
                // - Flag is true--combined with the reset() call below, this ensures that only one consumer will consume this action, preventing the behavior where a "dismiss" action also scrolls the previous page
                if displayed, tabReselectTracker.flag {
                    tabReselectTracker.reset()
                    action()
                }
            }
            .onAppear {
                if !displayed {
                    displayed = true
                }
            }
            .onDisappear {
                if displayed {
                    displayed = false
                }
            }
    }
}

extension View {
    func onReselectTab(action: @escaping () -> Void) -> some View {
        modifier(TabReselectionConsumer(action: action))
    }
}
