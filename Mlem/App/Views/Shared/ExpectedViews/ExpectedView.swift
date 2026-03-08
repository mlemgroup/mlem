//
//  ExpectedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-28.
//

import SwiftUI
import MlemMiddleware

/// View for animating content appearance when a given ValueProviding resolves.
/// Intended for tightly scoped, small views; may cause rendering issues on more complex views.
struct ExpectedView<Value, Content: View, Placeholder: View>: View {
    let value: any ValueProviding<Value>
    @ViewBuilder let view: (Value) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    init(
        _ value: any ValueProviding<Value>,
        view: @escaping (Value) -> Content,
        placeholder: @escaping () -> Placeholder = { EmptyView() }
    ) {
        self.value = value
        self.view = view
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            if let value = value.value {
                view(value)
                    .transition(.scale)
            } else {
                placeholder()
            }
        }
        .animation(.interactiveSpring, value: value.value == nil)
    }
}
