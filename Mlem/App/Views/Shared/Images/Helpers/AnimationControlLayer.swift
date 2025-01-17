//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var blurred: Bool = false
}

private struct AnimationControlLayer: ViewModifier {
    @Environment(\.blurred) var blurred
    
    @Binding var animating: Bool
    var muted: Binding<Bool>?
    
    // decouple controls state from blurred because the blur animation and material don't get along
    @State var showControls: Bool = true
    
    init(animating: Binding<Bool>, muted: Binding<Bool>?) {
        self._animating = animating
        self.muted = muted
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if animating {
                    Color.clear.contentShape(.rect)
                        .highPriorityGesture(TapGesture()
                            .onEnded {
                                animating = false
                            }
                        )
                } else if showControls {
                    PlayButton(postSize: .large)
                        .highPriorityGesture(TapGesture()
                            .onEnded {
                                animating = true
                            }
                        )
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
            .onChange(of: blurred, initial: true) {
                if blurred {
                    showControls = false
                } else {
                    animating = true
                    showControls = true
                }
            }
    }
}

extension View {
    func withAnimationControls(animating: Binding<Bool>, muted: Binding<Bool>? = nil) -> some View {
        modifier(AnimationControlLayer(animating: animating, muted: muted))
    }
}
