//
//  EventRowView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import FediverseEvents
import SwiftUI

struct EventRowView: View {
    let event: Event

    var body: some View {
        Button {
            
        } label: {
            
        }
        .buttonStyle(.empty)
        .padding(10)
        .padding(.horizontal, 5)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 25))
        .paletteBorder(cornerRadius: 25)
    }
}
