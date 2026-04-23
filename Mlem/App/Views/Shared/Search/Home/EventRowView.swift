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
        Text(event.name)
    }
}
