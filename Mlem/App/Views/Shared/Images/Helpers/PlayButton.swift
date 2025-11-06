//
//  PlayButton.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-27.
//

import SwiftUI

struct PlayButton: View {
    let fontSize: CGFloat
    
    init(postSize: PostSize) {
        self.fontSize = switch postSize {
        case .compact, .headline: 10
        case .tile: 20
        case .large: 30
        }
    }
    
    var body: some View {
        if #available(iOS 26, *) {
            label
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            label
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
        }
    }
    
    // TODO: iOS 18 deprecation remove
    var label: some View {
        Label {
            Text("Play")
        } icon: {
            Image(icon: .general.play)
                .symbolVariant(.fill)
                .font(.system(size: fontSize))
                .foregroundStyle(.themedBackground)
                .padding(0.6 * fontSize)
                .contentShape(.rect)
        }
        .labelStyle(.iconOnly)
    }
}
