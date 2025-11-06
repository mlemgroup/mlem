//
//  AnimationControlLayer.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import Media
import SwiftUI

private struct AnimationControlLayer: ViewModifier {
    @Environment(MediaControlState.self) var controlState
    @Environment(MediaView.Overlays.self) var overlays
    
    // decouple controls state from blurred because the blur animation and material don't get along
    @State var showControls: Bool = true
    
    func body(content: Content) -> some View {
        if controlState.canAnimate, overlays.controls {
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
                if overlays.nsfw, overlays.controls {
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
            muteButtonContent
                .padding([.bottom, .trailing], 5)
                .padding([.top, .leading], 15)
                .contentShape(.rect)
                .highPriorityGesture(TapGesture().onEnded {
                    controlState.muted = !controlState.muted
                })
                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
        }
    }
    
    // TODO: iOS 18 deprecation remove
    @ViewBuilder
    var muteButtonContent: some View {
        if #available(iOS 26, *) {
            muteButtonLabel
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            muteButtonLabel
                .background(.ultraThinMaterial, in: .circle)
        }
    }
    
    // TODO: iOS 18 deprecation remove
    var muteButtonLabel: some View {
        SmallOverlayButtonLabel(
            isOn: controlState.muted,
            text: (on: "Unmute", off: "Mute"),
            icons: (on: .general.mute, off: .general.unmute))
        .symbolVariant(.fill)
    }
}

extension View {
    func withAnimationControls() -> some View {
        modifier(AnimationControlLayer())
    }
}
