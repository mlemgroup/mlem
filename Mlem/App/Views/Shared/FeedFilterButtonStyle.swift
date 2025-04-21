//
//  FeedFilterButtonStyle.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-04.
//

import Icons
import SwiftUI

struct FeedFilterButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette
    
    let isOn: Bool
    var icon: Icon? = .general.dropDown
    
    @ScaledMetric(relativeTo: .footnote) var height: CGFloat = 32
    
    var iconRequiresCircle: Bool {
        switch icon {
        case .general.dropDown, .general.close: true
        default: false
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.label
            if let icon {
                Image(icon: icon)
                    .symbolRenderingMode(.hierarchical)
                    .padding(.trailing, 8)
                    .symbolVariant(iconRequiresCircle ? .circle.fill : .fill)
            }
        }
        .frame(height: height)
        .foregroundStyle(isOn ? .themedContrastingLabel : .themedAccent)
        .font(.footnote)
        .padding(icon == nil ? .horizontal : .leading, 12)
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
        icon: Icon? = .general.dropDown
    ) -> FeedFilterButtonStyle {
        .init(isOn: isOn, icon: icon)
    }
}
