//
//  ExpectedTextView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-19.
//

import SwiftUI
import ComponentViews
import MlemMiddleware

extension Font {
    // source: https://sarunw.com/posts/scaling-custom-fonts-automatically-with-dynamic-type/
    var leadingHeight: CGFloat {
        switch self {
        case .largeTitle: 41
        case .title: 34
        case .title2: 28
        case .title3: 25
        case .headline: 22
        case .body: 22
        case .callout: 21
        case .subheadline: 20
        case .footnote: 18
        case .caption: 16
        case .caption2: 13
        default:  22
        }
    }
}

struct ExpectedText: View {
    @Environment(\.font) var _font: Font?
    var font: Font { _font ?? .body }
    
    let text: ExpectedValue<String>
    
    init(_ text: ExpectedValue<String>) {
        self.text = text
    }
    
    var body: some View {
        ZStack { // ZStack to make the animation work correctliy
            if let text = text.value {
                Text(text)
                    .transition(.scale)
            } else {
                MockTextView()
                    .frame(height: font.leadingHeight)
                    .transition(.opacity)
            }
        }
        .animation(.interactiveSpring, value: text.value != nil)
    }
}
