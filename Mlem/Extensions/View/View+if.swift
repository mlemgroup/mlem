//
//  View+if.swift
//  Mlem
//
//  Created by Sjmarf on 05/02/2024.
//

import SwiftUI

// https://www.avanderlee.com/swiftui/conditional-view-modifier/

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, then transform: (_ content: Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifLet<Content: View, Value: Any>(
        _ value: Value?,
        then transform: (_ value: Value, _ content: Self) -> Content
    ) -> some View {
        // Using 'if let' here breaks it. I don't know why
        if value != nil {
            transform(value!, self)
        } else {
            self
        }
    }
}
