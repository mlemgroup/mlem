//
//  ReasonPickerView.swift
//  Mlem
//
//  Created by Sjmarf on 09/10/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct ReasonShortcutView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    @Binding var reason: String
    let rulesTarget: (any ProfileProviding)?
    
    init(reason: Binding<String>, rulesTarget: (any ProfileProviding)? = nil) {
        self._reason = reason
        self.rulesTarget = rulesTarget
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach([
                LocalizedStringResource("Spam"),
                LocalizedStringResource("Troll"),
                LocalizedStringResource("Abuse")
            ], id: \.key) { item in
                Text(item)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 10))
                    .contentShape(.rect)
                    .onTapGesture {
                        var item = item
                        // TODO: Set this to instance/community language?
                        item.locale = .init(languageCode: .english)
                        reason = String(localized: item)
                    }
            }
            if let rulesTarget, ![BlockNode](rulesTarget.description ?? "").rules().isEmpty {
                Label("\(rulesTarget.name) rules...", systemImage: "book.pages")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.themedAccent)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 10))
                    .onTapGesture {
                        navigation.openSheet(.rulesList(rulesTarget, callback: {
                            reason = $0
                        }))
                    }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init())
    }
}
