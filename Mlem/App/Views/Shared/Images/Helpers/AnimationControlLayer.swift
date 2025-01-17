//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SwiftUICore

extension EnvironmentValues {
    @Entry var blurred: Bool = false
}

private struct AnimationControlLayer: ViewModifier {
    @Environment(\.blurred) var blurred
    
    @Binding var animating: Bool
    var muted: Binding<Bool>?
    
    // decouple play button state from blurred because the blur animation and material don't get along
    @State var showPlayButton: Bool
    
    init(animating: Binding<Bool>, muted: Binding<Bool>?) {
        self._animating = animating
        self.muted = muted
        self.showPlayButton = !animating.wrappedValue
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: blurred) {
                if blurred {
                    showPlayButton = false
                } else {
                    animating = true
                    showPlayButton = true
                }
            }
            .overlay {
                if animating {
                    Color.clear.contentShape(.rect)
                        .onTapGesture {
                            animating = false
                        }
                } else if showPlayButton {
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
