//
//  ChildSizeReader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-22.
//
// adapted from https://stackoverflow.com/questions/56573373/swiftui-get-size-of-child

import Foundation
import SwiftUI

struct ChildSizeReader<Content: View>: View {
    @Binding var sizes: [BubblePickerItemFrame]
    let index: Int
    let spaceName: String
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: .init(
                                width: proxy.size.width,
                                offset: proxy.frame(in: .named(spaceName)).minX
                            ))
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            // This *should* never fail. But somehow it happened one time and
            // we got a TF crash, so there's an `if` statement now.
            if index < sizes.count {
                sizes[index] = preferences
            } else {
//                assertionFailure()
            }
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = BubblePickerItemFrame
    static var defaultValue: Value = .init(width: .zero, offset: .zero)

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
