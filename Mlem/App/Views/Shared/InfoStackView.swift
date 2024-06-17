//
//  InfoStackView.swift
//  Mlem
//
//  Created by Sjmarf on 16/06/2024.
//

import SwiftUI

struct InfoStackView: View {
    @Environment(Palette.self) var palette
    let readouts: [Readout]
    let showColor: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(readouts, id: \.viewId) { readout in
                HStack(spacing: 2) {
                    Image(systemName: readout.icon)
                    Text(readout.label ?? " ")
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(readout.label ?? "") ?? 0))
                        .animation(.default, value: readout.label)
                }
                .foregroundStyle(palette.secondary)
            }
        }
        .font(.footnote)
    }
}

private extension Readout {
    var viewId: Int {
        var hasher = Hasher()
        hasher.combine(id)
        // hasher.combine(self.icon)
        // hasher.combine(self.label)
        return hasher.finalize()
    }
}
