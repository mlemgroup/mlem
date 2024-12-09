//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SwiftUICore

private struct AnimationControlLayer: ViewModifier {
    @Binding var animating: Bool
    var soundOn: Binding<Bool>?
    
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
                            print("DEBUG tapped here")
                            animating = false
                        }
                }
            }
            .overlay(alignment: .topTrailing) {
                if let soundOn {
                    Image(systemName: soundOn.wrappedValue ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .padding(5)
                        .background {
                            Circle().foregroundStyle(.ultraThinMaterial)
                        }
                        .foregroundStyle(.white)
                        .padding([.top, .trailing], 5)
                        .padding([.bottom, .leading], 15)
                        .contentShape(.rect)
                        .onTapGesture {
                            soundOn.wrappedValue = !soundOn.wrappedValue
                        }
                }
            }
    }
}

extension View {
    func withAnimationControls(animating: Binding<Bool>, soundOn: Binding<Bool>? = nil) -> some View {
        modifier(AnimationControlLayer(animating: animating, soundOn: soundOn))
    }
}
