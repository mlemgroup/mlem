//
//  PlayButton.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-27.
//

import SwiftUI

struct PlayButton: View {
    @Environment(Palette.self) var palette
    
    let fontSize: CGFloat
    
    init(postSize: PostSize) {
        self.fontSize = switch postSize {
        case .compact, .headline: 10
        case .tile: 20
        case .large: 30
        }
    }
    
    var body: some View {
        Image(systemName: Icons.play)
            .font(.system(size: fontSize))
            .foregroundStyle(palette.background)
            .padding(0.6 * fontSize)
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
            }
    }
}
