//
//  FeedFilterButtonStyle.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-04.
//

import SwiftUI

struct FeedFilterButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette
    
    let isOn: Bool
    var systemImage: String? = Icons.dropDownCircleFill
    
    @ScaledMetric(relativeTo: .footnote) var height: CGFloat = 32
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.label
            if let systemImage {
                Image(systemName: systemImage)
                    .symbolRenderingMode(.hierarchical)
                    .padding(.trailing, 8)
            }
        }
        .frame(height: height)
        .foregroundStyle(isOn ? .themedContrastingLabel : .themedAccent)
        .font(.footnote)
        .padding(systemImage == nil ? .horizontal : .leading, 12)
        .background(
            Capsule()
                .fill(isOn ? palette.accent : .clear)
                .strokeBorder(.themedAccent, lineWidth: isOn ? 0 : 1)
        )
    }
}

extension ButtonStyle where Self == FeedFilterButtonStyle {
    @MainActor
    static func feedFilter(
        isOn: Bool = false,
        systemImage: String? = Icons.dropDownCircleFill
    ) -> FeedFilterButtonStyle {
        .init(isOn: isOn, systemImage: systemImage)
    }
}
