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
            sizes[index] = preferences
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
