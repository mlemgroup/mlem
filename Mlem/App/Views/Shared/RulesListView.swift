//
//  RulesListView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-11.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct RulesListView: View {
    let model: any Profile2Providing
    @Binding var reason: String

    var body: some View {
        let rules = [BlockNode](model.description ?? "").rules()
        if !rules.isEmpty {
            Section {
                ForEach(Array(rules.enumerated()), id: \.offset) { index, blocks in
                    HStack(spacing: 12) {
                        Image(systemName: "\(index + 1).circle.fill")
                            .foregroundStyle(.themedSecondary)
                            .fontWeight(.semibold)
                        Markdown(blocks, configuration: .default)
                            .frame(maxWidth: .infinity)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        switch blocks.first {
                        case let .paragraph(inlines: inlines), .heading(level: _, inlines: let inlines):
                            let text = inlines.stringLiteral
                            if text.count < 100 {
                                reason = "\(model.name) rule #\(index + 1): \"\(text)\""
                                return
                            }
                        default:
                            break
                        }
                        reason = "\(model.name) rule #\(index + 1)"
                    }
                }
            } header: {
                HStack {
                    CircleCroppedImageView(model, frame: 22)
                    Text("\(model.name) rules:")
                        .foregroundStyle(.themedSecondary)
                        .textCase(nil)
                }
            }
        }
    }
}
