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
    @Environment(\.colorScheme) var colorScheme

    let poll: PostPoll

    @State var resultsShownManually: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(poll.choices.enumerated()), id: \.offset) { _, choice in
                choiceView(choice)
            }
            if !poll.hasEnded {
                showResultsButtonView
            }
            footerView
        }
        .fixedSize(horizontal: false, vertical: true)
        .animation(.snappy(duration: 0.2, extraBounce: 0.2), value: showResults)
    }

    @ViewBuilder
    var showResultsButtonView: some View {
        Button {
            resultsShownManually.toggle()
            hapticManager.play(haptic: .gentleInfo, tier: .low)
        } label: {
            Label(resultsShownManually ? "Hide Results" : "Show Results", icon: .lemmy.pollPost)
                .foregroundStyle(.themedAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .padding(.vertical, 8)
                .background(.themedAccent.opacity(0.2), in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var footerView: some View {
        HStack {
            if let endDate = poll.endDate {
                Group {
                    if poll.hasEnded {
                        Text("Ended \(endDate, format: .relative(presentation: .named, unitsStyle: .wide))")
                    } else {
                        Text("Ends \(endDate, format: .relative(presentation: .named, unitsStyle: .wide))")
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
        HStack(alignment: .top) {
            if showCheckboxes {
                Checkbox(isOn: false)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(choice.label)
                    .padding(.vertical, 2)
                resultsDetailsView(choice)
            }
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
            HStack {
                if showResults {
                    Text(verbatim: "\(choice.percentage(poll: poll))%")
                        .foregroundStyle(.secondary)
                } else {
                    Text(verbatim: "?")
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(width: showResults ? 30 : 15, alignment: .center)
            .font(.footnote)
        }
    }

    @ViewBuilder
    func resultsBarView(_ choice: PostPollChoice) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(colorScheme == .dark ? .themedSecondaryGroupedBackground : .themedTertiary.opacity(0.5))
                let barWidth = proxy.size.width * CGFloat(choice.voteCount ?? 0) / CGFloat(max(1, poll.totalVotes))
                // This creates a half-capsule
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: .greatestFiniteMagnitude,
                    topTrailingRadius: .greatestFiniteMagnitude
                )
                .fill(.themedAccent)
                .frame(width: showResults ? barWidth : 0)
            }
            .clipShape(.capsule)
        }
        .frame(height: 4)
    }

    var showCheckboxes: Bool {
        !poll.hasEnded
    }

    var showResults: Bool {
        poll.hasEnded || resultsShownManually
    }
}
