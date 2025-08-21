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
    init(
        size: Binding<BubblePickerItemFrame>?,
        spaceName: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selectedSize = size
        self.spaceName = spaceName
        self.content = content
    }
    
    var selectedSize: Binding<BubblePickerItemFrame>?
    
    @State var size: BubblePickerItemFrame = .zero
    
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
        .onPreferenceChange(SizePreferenceKey.self) {
            if size == .zero {
                size = $0
            }
        }
        .onChange(of: onChangeHash, initial: true) {
            selectedSize?.wrappedValue = size
        }
    }
    
    var onChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(selectedSize == nil)
        hasher.combine(size)
        return hasher.finalize()
    }
}

private struct SizePreferenceKey: PreferenceKey {
    typealias Value = BubblePickerItemFrame
    static var defaultValue: Value = .init(width: .zero, offset: .zero)

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
