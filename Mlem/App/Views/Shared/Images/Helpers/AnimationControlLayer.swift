//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SwiftUICore

private struct AnimationControlLayer: ViewModifier {
    @Binding var animating: Bool
    var muted: Binding<Bool>?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if animating {
                    Color.clear.contentShape(.rect)
                        .onTapGesture {
                            animating = false
                        }
                } else {
                    PlayButton(postSize: .large)
                        .onTapGesture {
                            animating = true
                        }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let muted {
                    Image(systemName: muted.wrappedValue ? Icons.muted : Icons.unmuted)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .padding(5)
                        .background(.ultraThinMaterial, in: .circle)
                        .foregroundStyle(.white)
                        .padding([.top, .trailing], 5)
                        .padding([.bottom, .leading], 15)
                        .contentShape(.rect)
                        .onTapGesture {
                            muted.wrappedValue = !muted.wrappedValue
                        }
                }
            }
    }
}

extension View {
    func withAnimationControls(animating: Binding<Bool>, muted: Binding<Bool>? = nil) -> some View {
        modifier(AnimationControlLayer(animating: animating, muted: muted))
    }
}
