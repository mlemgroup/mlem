//
//  InfoStackView.swift
//  Mlem
//
//  Created by Sjmarf on 16/06/2024.
//

import MlemMiddleware
import SwiftUI

struct InfoStackView: View {
    @Environment(Palette.self) private var palette
    
    let readouts: [Readout]
    let showColor: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(readouts, id: \.viewId) { readout in
                HStack(spacing: 2) {
                    Image(systemName: readout.icon)
                    Group {
                        if readout.label?.allSatisfy(\.isNumber) ?? false {
                            Text(readout.label ?? " ")
                                .monospacedDigit()
                        } else {
                            Text(readout.label ?? " ")
                        }
                    }
                    .contentTransition(.numericText(value: Double(readout.label ?? "") ?? 0))
                    .animation(.default, value: readout.label)
                }
                .foregroundStyle((showColor ? readout.color : nil) ?? palette.secondary)
            }
        }
        .font(.footnote)
        .geometryGroup()
    }
}

extension InfoStackView {
    init(post: any Post1Providing, readouts: [PostBarConfiguration.ReadoutType], showColor: Bool) {
        self.readouts = readouts.map { post.readout(type: $0) }
        self.showColor = showColor
    }
}

private extension Readout {
    var viewId: Int { id.hashValue }
}
