//
//  TranslatableMarkdownView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-16.
//

import ComponentViews
import SwiftUI
import Theming
import MlemMiddleware

struct TranslatableMarkdownView: View {
    let markdown: TranslatableMarkdown
    var configuration: MarkdownConfigurationType = .default
    var showLinkCaptions: Bool = true

    @ViewBuilder
    var body: some View {
        VStack {
            switch markdown.translated {
            case let .translated(translated):
                MarkdownWithLinkList(translated, showLinkCaptions: showLinkCaptions)
                    .transition(.asymmetric(insertion: .glowReveal, removal: .opacity))
            case .translating:
                MarkdownWithLinkList(markdown.markdown, showLinkCaptions: showLinkCaptions)
                    .transition(.asymmetric(insertion: .opacity, removal: .glowReveal))
                    .modifier(GlowFlashModifier())
            case .untranslated:
                MarkdownWithLinkList(markdown.markdown, showLinkCaptions: showLinkCaptions)
                    .transition(.opacity)
            }
        }
    }
}

private struct GlowFlashModifier: ViewModifier {
    @Environment(\.palette) var palette

    @State var trigger: Bool = false

    func body(content: Content) -> some View {
        content
            .phaseAnimator([false, true, false], trigger: trigger) { view, phase in
                view
                    .overlay {
                        ThemedColor.themedColorfulAccent(9)
                            .resolve(with: palette)
                            .opacity(phase ? 0.7 : 0)
                            .blendMode(.sourceAtop)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    trigger = true
                }
            }
    }
}
