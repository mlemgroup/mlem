//
//  EventRowView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import FediverseEvents
import SwiftUI

struct EventRowView: View {
    @Environment(\.openURL) var openURL

    let event: Event

    var body: some View {
        Button {
            if let url = event.navigationUrl {
                openURL(url)
            } 
        } label: {
            HStack(spacing: 15) {
                CircleCroppedImageView(
                    url: event.logos.first?.url,
                    frame: SearchHomeLabelStyle.iconSize,
                    fallback: .event
                )
                Text(event.name)
                Spacer()
                dateView
                .padding(.trailing, 15)
            }
        }
        .buttonStyle(.chevron)
    }

    @ViewBuilder
    var dateView: some View {
        Group {
            if event.start < .now {
                Text("Ends \(event.end, format: .relative(presentation: .numeric, unitsStyle: .wide))")
            } else {
                Text("Starts \(event.start, format: .relative(presentation: .numeric, unitsStyle: .wide))")
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
