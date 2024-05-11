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
    
    var action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: tabReselectTracker.flag) {
                action()
            }
    }
}

extension View {
    func onReselectTab(action: @escaping () -> Void) -> some View {
        modifier(TabReselectionConsumer(action: action))
    }
}
