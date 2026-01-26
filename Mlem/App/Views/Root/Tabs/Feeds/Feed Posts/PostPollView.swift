//
//  PostPollView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-26.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct PostPollView: View {
    @Environment(\.hapticManager) var hapticManager
    @Environment(\.toastModel) var toastModel

    let poll: PostPoll

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(poll.choices.enumerated()), id: \.offset) { _, choice in
                choiceView(choice)
            }
            footerView
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var footerView: some View {
        HStack {
            if let endDate = poll.endDate {
                Group {
                    if poll.hasEnded {
                        Text("Poll ended \(endDate, format: .relative(presentation: .named, unitsStyle: .abbreviated))")
                    } else {
                        Text("Poll ends \(endDate, format: .relative(presentation: .named, unitsStyle: .abbreviated))")
                    }
                }
            }
            Spacer()
            Text("\(poll.totalVotes) votes")
        }
        .padding(.horizontal, 8)
        .foregroundStyle(.themedSecondary)
        .font(.footnote)
    }


    @ViewBuilder
    func choiceView(_ choice: PostPollChoice) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                if showCheckboxes {
                    Checkbox(isOn: false)
                }
                Text(choice.label)
                    .padding(.vertical, 2)
            }
            resultsDetailsView(choice)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 16)
        .padding(.leading, showCheckboxes ? 8 : 16)
        .padding(.vertical, 8)
        .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: 16))
        .onTapGesture {
            if !poll.hasEnded {
                hapticManager.play(haptic: .gentleInfo, tier: .low)
                toastModel?.add(.basic(String("🚧 WIP 🚧")))
            }
        }
    }

    @ViewBuilder
    func resultsDetailsView(_ choice: PostPollChoice) -> some View {
        HStack {
            resultsBarView(choice)
            Text(verbatim: "\(Int(100 * Double(choice.voteCount ?? 0) / Double(poll.totalVotes)))%")
                .foregroundStyle(.secondary)
                .font(.footnote)
        }
    }

    @ViewBuilder
    func resultsBarView(_ choice: PostPollChoice) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.themedSecondaryGroupedBackground)
                if showResults {
                    // This creates a half-capsule
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: .greatestFiniteMagnitude,
                        topTrailingRadius: .greatestFiniteMagnitude
                    )
                    .fill(.themedAccent)
                    .frame(width: proxy.size.width * CGFloat(choice.voteCount ?? 0) / CGFloat(poll.totalVotes))
                }
            }
            .clipShape(.capsule)
        }
        .frame(height: 4)
    }

    var showCheckboxes: Bool {
        !poll.hasEnded
    }

    var showResults: Bool {
        poll.hasEnded
    }
}
