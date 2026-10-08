//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-23.
//

import Actions
import MlemMiddleware
import QuickSwipes
import SwiftUI

extension View {
    @ViewBuilder
    func quickSwipes(
        leading: [any Action] = [],
        trailing: [any Action] = [],
        leadingBuffer: SwipeBuffer
    ) -> some View {
        quickSwipes(.init(leadingActions: leading, trailingActions: trailing, leadingBuffer: leadingBuffer))
    }
}
