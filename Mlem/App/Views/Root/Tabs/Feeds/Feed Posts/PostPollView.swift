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
    let poll: PostPoll

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(poll.choices.enumerated()), id: \.offset) { _, choice in
                choiceView(choice)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    func choiceView(_ choice: PostPollChoice) -> some View {
        HStack(alignment: .top) {
            Checkbox(isOn: false)
            Text(choice.label)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: 16))
    }
}
