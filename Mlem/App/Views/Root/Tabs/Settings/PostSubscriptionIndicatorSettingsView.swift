//
//  PostSubscriptionIndicatorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import SwiftUI

struct PostSubscriptionIndicatorSettingsView: View {
    @Environment(Palette.self) var palette
    
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
                cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 0)
            )
            .fill(palette.tertiaryGroupedBackground)
            .frame(height: 100)
            .overlay(alignment: .topLeading) {
                HStack {
                    CircleCroppedImageView(url: nil, frame: 30, fallback: .person)
                        .opacity(0.8)
                    Circle()
                        .fill(palette.secondary)
                        .frame(width: 10, height: 10)
                        .padding(.leading, 5)
                    Text(
                        "community\(Text(verbatim: "@\(String(localized: "instance.com"))").foregroundColor(palette.tertiary))"
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
            }
            .padding([.top, .leading], 20)
            .listRowInsets(.init())
        }
    }
}
