//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SwiftUICore

private struct AnimationControlLayer: ViewModifier {
    @Binding var animating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if !animating {
                    PlayButton(postSize: .large)
                        .onTapGesture {
                            animating = true
                        }
                } else {
                    Color.clear.contentShape(.rect)
                        .onTapGesture {
                            animating = false
                        }
                }
            }
    }
}

extension View {
    func withAnimationControls(animating: Binding<Bool>) -> some View {
        modifier(AnimationControlLayer(animating: animating))
    }
}
