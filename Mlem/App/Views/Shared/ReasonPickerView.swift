//
//  ReasonPickerView.swift
//  Mlem
//
//  Created by Sjmarf on 09/10/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct ReasonPickerView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @Binding var reason: String
    @State var community: (any Community)?
    
    init(reason: Binding<String>, community: (any Community)?) {
        self._reason = reason
        self._community = .init(wrappedValue: community)
    }
    
    var body: some View {
        Group {
            suggestions
            if let community {
                RulesListView(model: community, reason: $reason)
            }
            if let instance = appState.firstSession.instance {
                RulesListView(model: instance, reason: $reason)
            }
        }
    }
    
    @ViewBuilder
    var suggestions: some View {
        Section {
            HStack(spacing: 12) {
                ForEach([
                    LocalizedStringResource("Spam"),
                    LocalizedStringResource("Troll"),
                    LocalizedStringResource("Abuse")
                ], id: \.key) { item in
                    Text(item)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: 10))
                        .contentShape(.rect)
                        .onTapGesture {
                            var item = item
                            // TODO: Set this to instance/community language?
                            item.locale = .init(languageCode: .english)
                            reason = String(localized: item)
                        }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
        }
    }
}
