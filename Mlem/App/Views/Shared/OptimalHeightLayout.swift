//
//  OptimalHeightLayout.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-23.
//

import SwiftUI

// https://stackoverflow.com/a/77631512/17629371
struct OptimalHeightLayout: Layout {
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let result: CGSize
        if let firstSubview = subviews.first {
            let containerWidth = proposal.width ?? .infinity
            let size = firstSubview.sizeThatFits(.init(width: containerWidth, height: nil))
            result = CGSize(width: containerWidth, height: size.height)
        } else {
            result = .zero
        }
        return result
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        if let firstSubview = subviews.first {
            firstSubview.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY),
                proposal: .init(width: bounds.width, height: bounds.height)
            )
        }
    }
}
