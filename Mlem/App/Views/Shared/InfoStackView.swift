//
//  InfoStackView.swift
//  Mlem
//
//  Created by Sjmarf on 16/06/2024.
//

import MlemMiddleware
import SwiftUI

struct InfoStackView: View {
    let readouts: [Readout]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(readouts, id: \.viewId) { readout in
                ReadoutView(readout: readout)
            }
        }
        .geometryGroup()
    }
}

struct ReadoutView: View {
    @Environment(\.palette) var palette
    
    let readout: Readout
    
    var body: some View {
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
            if let value = readout.value {
                Text(value)
                    .monospacedDigit()
                    .foregroundStyle(readout.valueColor ?? .themedSecondary)
            }
        }
        .foregroundStyle(readout.color ?? .themedSecondary)
        .font(.footnote)
        .lineLimit(1)
    }
}

extension InfoStackView {
    init(post: Post, readouts: [PostBarConfiguration.ReadoutType], coloredReadouts: Set<PostBarConfiguration.ReadoutType>) {
        self.readouts = readouts.compactMap { post.readout(type: $0, showColor: coloredReadouts.contains($0)) }
    }
    
    init(
        comment: Comment,
        readouts: [CommentBarConfiguration.ReadoutType],
        coloredReadouts: Set<CommentBarConfiguration.ReadoutType>
    ) {
        self.readouts = readouts.compactMap { comment.readout(type: $0, showColor: coloredReadouts.contains($0)) }
    }
}

private extension Readout {
    var viewId: Int { id.hashValue }
}
