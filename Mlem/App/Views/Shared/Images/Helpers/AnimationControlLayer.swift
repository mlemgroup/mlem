//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SwiftUI

private struct AnimationControlLayer: ViewModifier {
    @Environment(MediaControlState.self) var controlState
    
    // decouple controls state from blurred because the blur animation and material don't get along
    @State var showControls: Bool = true
    
    func body(content: Content) -> some View {
        if controlState.animationAvailable, controlState.enableAnimation, controlState.enableControlOverlay {
            contentWithControls(content: content)
        } else {
            content
        }
    }
    
    @ViewBuilder
    func contentWithControls(content: Content) -> some View {
        content
            .overlay {
                if controlState.animating {
                    Color.clear.contentShape(.rect)
                        .highPriorityGesture(TapGesture()
                            .onEnded {
                                controlState.animating = false
                            }
                        )
                } else if showControls {
                    PlayButton(postSize: .large)
                        .highPriorityGesture(TapGesture()
                            .onEnded {
                                controlState.animating = true
                            }
                        )
                }
            }
            .overlay(alignment: .bottomTrailing) {
                muteButton
            }
            .onChange(of: controlState.blurred, initial: true) {
                if controlState.enableNsfwOverlay, controlState.enableControlOverlay {
                    if controlState.blurred {
                        showControls = false
                    } else {
                        controlState.animating = true
                        showControls = true
                    }
                }
            }
    }
    
    @ViewBuilder
    var muteButton: some View {
        if controlState.audioAvailable {
            Image(systemName: controlState.muted ? Icons.muted : Icons.unmuted)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(5)
                .background(.ultraThinMaterial, in: .circle)
                .foregroundStyle(.white)
                .padding([.bottom, .trailing], 5)
                .padding([.top, .leading], 15)
                .contentShape(.rect)
                .highPriorityGesture(TapGesture().onEnded {
                    controlState.muted = !controlState.muted
                })
                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
        }
    }
}

extension View {
    func withAnimationControls() -> some View {
        modifier(AnimationControlLayer())
    }
}
