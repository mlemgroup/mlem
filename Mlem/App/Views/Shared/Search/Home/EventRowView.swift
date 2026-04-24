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
            HStack(spacing: 15) {
                CircleCroppedImageView(
                    url: event.logos.first?.url,
                    frame: SearchHomeLabelStyle.iconSize,
                    fallback: .image
                )
                Text(event.name)
                Spacer()
            }
        }
        .buttonStyle(.chevron)
    }
}
