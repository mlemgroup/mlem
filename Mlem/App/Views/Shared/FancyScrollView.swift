//
//  FancyScrollView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import SwiftUI

struct IsAtTopPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {}
}

struct FancyScrollView<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    
    var content: Content
    @Binding var isAtTop: Bool
    @Binding var scrollToTopTrigger: Bool // TODO: investigate unifying this and isAtTop
    var reselectAction: (() -> Void)?

    private let topId: String = "scrollToTop"
    
    init(
        scrollToTopTrigger: Binding<Bool> = .constant(false),
        reselectAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        self._isAtTop = isAtTop
        self._scrollToTopTrigger = scrollToTopTrigger
        self.reselectAction = reselectAction
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetKey.self,
                            value: geo.frame(in: .named("scrollView")).origin.y >= 0
                        )
                        .frame(width: 0, height: 0)
                        .id(topId)
                    }
                    content
                }
            }
            .onReselectTab {
                if isAtTop {
                    if let reselectAction {
                        reselectAction()
                    } else {
                        dismiss()
                    }
                } else {
                    withAnimation {
                        proxy.scrollTo(topId)
                    }
                }
            }
            .onChange(of: scrollToTopTrigger) {
                withAnimation {
                    proxy.scrollTo(topId)
                }
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                if offset != isAtTop {
                    isAtTop = offset
                }
            }
        }
        .preference(key: IsAtTopPreferenceKey.self, value: isAtTop)
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue = true
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}
