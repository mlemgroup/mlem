//
//  InteractionBarCounterLabelView.swift
//  Mlem
//
//  Created by Sjmarf on 17/08/2024.
//

import SwiftUI

struct InteractionBarCounterLabelView: View {
    let appearance: CounterAppearance
    
    init(_ appearance: CounterAppearance) {
        self.appearance = appearance
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let leading = appearance.leading {
                InteractionBarActionLabelView(leading)
            }
            Text(appearance.value?.description ?? "")
                .monospacedDigit()
            if let trailing = appearance.trailing {
                InteractionBarActionLabelView(trailing)
            }
        }
        .padding(paddingEdges, 6)
    }
    
    var paddingEdges: Edge.Set {
        if appearance.trailing == nil { return .trailing }
        if appearance.leading == nil { return .leading }
        return []
    }
}
