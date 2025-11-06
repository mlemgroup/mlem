//
//  NsfwOverlayView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-03.
//

import Foundation
import SwiftUI
import Media

struct NsfwOverlay: View {
    @Environment(MediaControlState.self) var controlState
        
    @MainActor
    func setBlurred(_ newValue: Bool) {
        withAnimation(newValue ? .easeIn(duration: 0.15) : .easeOut(duration: 0.12)) {
            controlState.blurred = newValue
        }
    }
    
    var body: some View {
        if controlState.blurred {
            VStack(spacing: 8) {
                Image(icon: .general.warning)
                    .font(.largeTitle)
                Text("NSFW")
                    .fontWeight(.black)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .onTapGesture {
                setBlurred(false)
            }
        } else {
            Button {
                setBlurred(true)
            } label: {
                blurLabel
            }
            .buttonStyle(.plain)
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    // TODO: iOS 18 deprecation remove
    @ViewBuilder
    var blurLabel: some View {
        if #available(iOS 26, *) {
            blurLabelContent
                .glassEffect(.clear.interactive(), in: .circle)
        } else {
            blurLabelContent
                .background(.thinMaterial, in: .circle)
        }
    }
    
    var blurLabelContent: some View {
        SmallOverlayButtonLabel(text: "Blur", icon: .general.hide)
    }
}
