//
//  PostSubscriptionIndicatorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//

import SwiftUI

struct PostSubscriptionIndicatorSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.palette) var palette
    
    @Setting(\.post_showSubscribedStatus) var showSubscribedStatus
    
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
                cornerRadii: .init(
                    topLeading: 16,
                    bottomLeading: 0,
                    bottomTrailing: 26,
                    topTrailing: 0
                )
            )
            .fill(.themedTertiaryGroupedBackground)
            .strokeBorder(colorScheme == .light ? .themedSecondaryGroupedBackground : .clear, lineWidth: 2)
            .frame(height: 100)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 0) {
                    CircleCroppedImageView(url: nil, frame: 30, fallback: .communityAvatar)
                        .opacity(0.8)
                    Circle()
                        .fill(.themedSecondary)
                        .frame(width: showSubscribedStatus ? 10 : 0, height: 10)
                        .opacity(showSubscribedStatus ? 10 : 0)
                        .padding(.leading, showSubscribedStatus ? 12 : 5)
                        .padding(.trailing, showSubscribedStatus ? 10 : 5)
                    labelText
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.title2)
                        .foregroundStyle(.themedSecondary)
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
    
    var labelText: Text {
        let string = String(localized: "news@example.com")
        let parts = string.split(separator: "@")
        guard parts.count == 2 else {
            assertionFailure()
            return Text(string)
        }
        return Text(parts[0]) + Text(verbatim: "@\(parts[1])").foregroundColor(palette.label.tertiary)
    }
}
