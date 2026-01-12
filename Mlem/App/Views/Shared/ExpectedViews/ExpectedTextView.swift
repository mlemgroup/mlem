//
//  ExpectedTextView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-19.
//

import SwiftUI
import MlemMiddleware

struct ExpectedText: View {
    let text: ExpectedValue<String>
    private let placeholder: String

    init(_ text: ExpectedValue<String>, expectedLength: Int = 15) {
        self.text = text
        self.placeholder = String(repeating: "a", count: expectedLength)
    }
    
    var body: some View {
        ZStack { // ZStack to make the animation work correctliy
            if let text = text.value {
                Text(text)
                    .transition(.scale)
            } else {
                Text(verbatim: placeholder)
                    .redacted(reason: .placeholder)
                    .transition(.opacity)
            }
        }
        .animation(.interactiveSpring, value: text.value != nil)
    }
}
