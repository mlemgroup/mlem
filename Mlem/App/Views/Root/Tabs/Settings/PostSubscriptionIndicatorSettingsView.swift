//
//  PostSubscriptionIndicatorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import SwiftUI

struct PostSubscriptionIndicatorSettingsView: View {
    @Environment(Palette.self) var palette
    @Environment(\.colorScheme) var colorScheme
    
    @Setting(\.showSubscribedStatus) var showSubscribedStatus
    
    var body: some View {
        Form {
            previewSection
            Section {
                Toggle("Subscription Indicator", isOn: $showSubscribedStatus)
            }
        }
        .contentMargins(.top, 16)
        .navigationTitle("Subscription Indicator")
    }
    
    @ViewBuilder
    var previewSection: some View {
        Section {
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 16, bottomLeading: 0, bottomTrailing: 10, topTrailing: 0)
            )
            .fill(palette.tertiaryGroupedBackground)
            .strokeBorder(colorScheme == .light ? palette.secondaryGroupedBackground : .clear, lineWidth: 2)
            .frame(height: 100)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 0) {
                    CircleCroppedImageView(url: nil, frame: 30, fallback: .person)
                        .opacity(0.8)
                    Circle()
                        .fill(palette.secondary)
                        .frame(width: showSubscribedStatus ? 10 : 0, height: 10)
                        .opacity(showSubscribedStatus ? 10 : 0)
                        .padding(.leading, showSubscribedStatus ? 12 : 5)
                        .padding(.trailing, showSubscribedStatus ? 10 : 5)
                    Text(
                        "news\(Text(verbatim: "@\(String(localized: "example.com"))").foregroundColor(palette.tertiary))"
                    )
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title2)
                    .foregroundStyle(palette.secondary)
                    .opacity(0.8)
                    .mask {
                        LinearGradient(colors: [.black, .black.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                    }
                    .offset(y: -1)
                }
                .padding([.top, .leading], 20)
                .animation(.bouncy, value: showSubscribedStatus)
            }
            .padding([.top, .leading], 20)
            .listRowInsets(.init())
        }
    }
}
