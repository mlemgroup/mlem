//
//  NoPaddingTipViewStyle.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-24.
//

import TipKit

/// Minimal TipViewStyle with no padding, suitable for embedding in views that force padding (e.g., Form)
/// Recommended to use .tipBackground(.clear).tipCornerRadius(0) along with this style
struct NoPaddingTipViewStyle: TipViewStyle {
    func makeBody(configuration: TipViewStyle.Configuration) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                configuration.title?.bold()
                
                Spacer()
                
                Button("Close", icon: .general.close) {
                    configuration.tip.invalidate(reason: .tipClosed)
                }
                .font(.title2)
                .labelStyle(.iconOnly)
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.themedSecondary)
                .buttonStyle(.plain)
                .aspectRatio(1, contentMode: .fill) // SwiftUI gets weird ideas about what shape this view should be
            }
            
            configuration.message
        }
    }
}
