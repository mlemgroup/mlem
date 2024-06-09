//
//  FancyScrollView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import SwiftUI
import SwiftUIIntrospect

struct FancyScrollView<Content: View>: View {
    private class ScrollViewModel: NSObject {
        var scrollView: UIScrollView?
        var observation: NSKeyValueObservation?
    }
    
    @Environment(\.dismiss) var dismiss
    
    @ViewBuilder var content: () -> Content
    @Binding var isAtTop: Bool
    @Binding var scrollToTopTrigger: Bool
    var reselectAction: (() -> Void)?

    private let model: ScrollViewModel = .init()
    private let topId: String = "scrollToTop"
    
    init(
        isAtTop: Binding<Bool> = .constant(false),
        scrollToTopTrigger: Binding<Bool> = .constant(false),
        reselectAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self._isAtTop = isAtTop
        self._scrollToTopTrigger = scrollToTopTrigger
        self.reselectAction = reselectAction
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 0)
                        .id(topId)
                    content()
                }
            }
            .introspect(.scrollView, on: .iOS(.v16, .v17)) { scrollView in
                Task { @MainActor in
                    model.scrollView = scrollView
                    model.observation = scrollView.observe(\.contentOffset) { scrollView, _ in
                        Task { @MainActor [self] in
                            let newValue = scrollView.contentOffset.y <= -scrollView.safeAreaInsets.top
                            if newValue != isAtTop {
                                isAtTop = newValue
                            }
                        }
                    }
                }
            }
            .onReselectTab {
                if let scrollView = model.scrollView {
                    if scrollView.contentOffset.y <= -scrollView.safeAreaInsets.top {
                        if let reselectAction {
                            reselectAction()
                        } else {
                            dismiss()
                        }
                    } else {
                        // I tried using `scrollView.setContentOffset` here instead,
                        // but it acts weirdly when the ScrollView contains a long LazyVStack :(
                        // - Sjmarf 2024-05-31
                        withAnimation {
                            proxy.scrollTo(topId)
                        }
                    }
                }
            }
            .onChange(of: scrollToTopTrigger) {
                withAnimation {
                    proxy.scrollTo(topId)
                }
            }
        }
    }
}
