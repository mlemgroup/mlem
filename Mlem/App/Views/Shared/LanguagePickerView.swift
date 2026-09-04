//
//  LanguagePickerView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-04.
//

import MlemMiddleware
import SwiftUI

struct LanguagePickerView: View {
    @Environment(AppState.self) var appState

    let api: ApiClient
    @Binding var selected: Locale.Language?

    var body: some View {
        Menu {
            Picker("Language", selection: $selected) {
                Text("None")
                    .tag(nil as Locale.Language?)
                ForEach(languages, id: \.languageCode) { language in
                    let code = language.languageCode?.identifier ?? ""
                    let locale = Locale(languageCode: language.languageCode)
                    Text(locale.localizedString(forLanguageCode: code)?.capitalized ?? "")
                        .tag(language)
                }
            }
        } label: {
            Group {
                if let languageCode = selected?.languageCode {
                    Text(languageCode.identifier.uppercased())
                } else {
                    Label("Language", systemImage: "globe.americas.fill")
                        .labelStyle(.iconOnly)
                }
            }
            .foregroundStyle(.tint)
            .fontDesign(.rounded)
            .fontWeight(.semibold)
            .font(.callout)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.tint.opacity(0.2), in: .rect(cornerRadius: Constants.main.barIconCornerRadius))
        }
    }

    var languages: [Locale.Language] {
        api.myInstance?.languages(withIds: api.myPerson?.discussionLanguageIds.value ?? []) ?? []
    }
}
