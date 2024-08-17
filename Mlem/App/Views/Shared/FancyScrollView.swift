//
//  FancyScrollView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import SwiftUI

struct IsAtTopPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = true
    static func reduce(value: inout Bool, nextValue: () -> Bool) {}
}

struct FancyScrollView<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    
    @ViewBuilder var content: () -> Content
    @Binding var scrollToTopTrigger: Bool // TODO: investigate unifying this and isAtTop
    var reselectAction: (() -> Void)?
    
    @State var isAtTop: Bool = true

    private let topId: String = "scrollToTop"
    
    init(
        scrollToTopTrigger: Binding<Bool> = .constant(false),
        reselectAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self._scrollToTopTrigger = scrollToTopTrigger
        self.reselectAction = reselectAction
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: IsAtTopPreferenceKey.self,
                            // This must be `Int` to account for floating point error
                            value: Int(geo.frame(in: .named("scrollView")).origin.y) >= 0
                        )
                        .id(topId)
                    }
                    .frame(width: 0, height: 0)
                    content()
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
            .onPreferenceChange(IsAtTopPreferenceKey.self) { offset in
                if offset != isAtTop {
                    isAtTop = offset
                }
            }
        }
    }
}
