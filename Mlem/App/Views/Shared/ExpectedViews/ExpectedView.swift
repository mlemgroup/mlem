//
//  ExpectedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-28.
//

import SwiftUI
import MlemMiddleware

struct ExpectedView<Value, Content: View, Placeholder: View>: View {
    let value: ExpectedValue<Value>
    @ViewBuilder let view: (Value) -> Content
    @ViewBuilder let placeholder: (() -> Placeholder)
    
    init(_ value: ExpectedValue<Value>, view: @escaping (Value) -> Content, placeholder: @escaping (() -> Placeholder) = { EmptyView() }) {
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
