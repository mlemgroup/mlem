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
        HStack {
            if let leading = appearance.leading {
                InteractionBarActionLabelView(leading)
            }
            Text(appearance.value?.description ?? "")
                .monospacedDigit()
            if let trailing = appearance.trailing {
                InteractionBarActionLabelView(trailing)
            }
        }
    }
}
