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
            if let endDate = poll.endDate {
                Group {
                    if poll.hasEnded {
                        Text("Poll ended \(endDate, format: .relative(presentation: .named, unitsStyle: .abbreviated))")
                    } else {
                        Text("Poll ends \(endDate, format: .relative(presentation: .named, unitsStyle: .abbreviated))")
                    }
                }
                .foregroundStyle(.themedSecondary)
                .font(.footnote)
                .padding(.leading, 8)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    func choiceView(_ choice: PostPollChoice) -> some View {
        HStack(alignment: .top) {
            if showCheckboxes {
                Checkbox(isOn: false)
            }
            Text(choice.label)
                .padding(.vertical, 2)
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

    var showCheckboxes: Bool {
        !poll.hasEnded
    }
}
